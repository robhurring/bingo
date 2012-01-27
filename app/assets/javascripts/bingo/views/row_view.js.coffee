# controls a single row of cells, not entirely useful
window.RowView = Backbone.View.extend
  className: 'clearfix'

  render: ->
    _.each @options.data, (col, index) =>
      cell = new Cell _.extend(col, {row: @options.row_index, col: index})
      view = new CellView {model: cell, collection: @collection}
      $(@el).append view.render().el
    @
