# renders the playing board
class window.BoardView extends Backbone.View
  className: 'card'

  render: ->
    _.each Card.matrix, (row, index) =>
      view = new RowView {data: row, row_index: index, collection: @collection}
      $(@el).append view.render().el
    @