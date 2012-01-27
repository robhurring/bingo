# renders the playing board
window.BoardView = Backbone.View.extend
  className: 'card'

  render: ->
    _.each Card.matrix, (row, index) =>
      view = new RowView {data: row, row_index: index, collection: @collection}
      $(@el).append view.render().el
    @