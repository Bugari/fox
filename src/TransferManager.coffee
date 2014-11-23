class TransferManager
  constructor: () ->
    @transfers = []
  handleMessage: (message) ->
    transfer = _.find @transfers, (x) -> x.sender == message.from && x.id == message.id
    if transfer?
      transfer.handle(message)
    else
      @createTransfer(message)

  createTransfer: (message) ->
    DownloadTransfer.create(message).then (transfer) =>
      @transfers.push transfer if transfer?
    .done()

  removeDone: () ->
    @transfers = _.filter @transfers, (x) -> x.isDone()

