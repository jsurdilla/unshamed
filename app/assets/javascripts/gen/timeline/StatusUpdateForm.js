/**
 * @jsx React.DOM
 */

angular.module('unshamed.timeline.components')
  .factory('StatusUpdateForm', StatusUpdateForm);

// Status update widget which includes the textarea and the submit button.
StatusUpdateForm.$inject = ['Post'];
function StatusUpdateForm(Post) {
  return React.createClass({
    getInitialState: function() {
      return { okToSubmit: false }
    },

    componentDidMount: function() {
      // hide the actions bar.
      this.refs.actionsPanel.getDOMNode().style.display = 'none';
    },

    showActionsPanel: function() {
      this.refs.actionsPanel.getDOMNode().style.display = 'block';
    },

    setSubmitButtonState: function() {
      var updateText = this.refs.updateText.getDOMNode();
      this.setState({ okToSubmit: updateText.value.trim() != '' });
    },

    postStatusUpdate: function() {
      var updateText = this.refs.updateText.getDOMNode();
      this.setState({ okToSubmit: false });

      Post.save({ body: updateText.value.trim() }).$promise.then(function(data) {
        updateText.value = '';
        if (this.props.onNewStatusUpdate) {
          this.props.onNewStatusUpdate(data.post);
        }
      }.bind(this));
    },

    render: function() {
      return (
        React.createElement("div", {id: "status-update"}, 
          React.createElement("textarea", {placeholder: "How are you today?", onFocus: this.showActionsPanel, onChange: this.setSubmitButtonState, ref: "updateText"}), 
          React.createElement("div", {className: "action clearfix", ref: "actionsPanel"}, 
            React.createElement("button", {className: "btn btn-sm btn-primary pull-right", disabled: !this.state.okToSubmit, onClick: this.postStatusUpdate, ref: "submitButton"}, "Post")
          )
        )
      );
    }
  });
};


