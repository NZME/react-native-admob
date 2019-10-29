import React from 'react';
import { requireNativeComponent } from 'react-native';

export const MediaViewContext = React.createContext({
  register: () => {
    throw new Error('Stub!');
  },
  unregister: () => {
    throw new Error('Stub!');
  }
});

export const NativeMediaView = requireNativeComponent('RNNativeAdsMediaView');

class MediaViewChild extends React.Component {
  constructor() {
    super(...arguments);
    this.mediaView = null;
    this.handleMediaViewMount = (ref) => {
      if (this.mediaView) {
        this.props.unregister();
        this.mediaView = null;
      }
      if (ref) {
        this.props.register(ref);
        this.mediaView = ref;
      }
    };
  }
  render() {
    return <NativeMediaView {...this.props} ref={this.handleMediaViewMount}/>;
  }
}
export default class MediaView extends React.Component {
  render() {
    return (<MediaViewContext.Consumer>
      {(contextValue) => (<MediaViewChild {...this.props} {...contextValue}/>)}
    </MediaViewContext.Consumer>);
  }
}
