import React from 'react';
import { requireNativeComponent } from 'react-native';

export const AdIconViewContext = React.createContext({
  register: () => {
    throw new Error('Stub!');
  },
  unregister: () => {
    throw new Error('Stub!');
  }
});

export const NativeAdIconView = requireNativeComponent('RNNativeAdsAdIconView');

class AdIconViewChild extends React.Component {
  constructor() {
    super(...arguments);
    this.iconView = null;
    this.handleAdIconViewRef = (ref) => {
      if (this.iconView) {
        this.props.unregister();
        this.iconView = null;
      }
      if (ref) {
        this.props.register(ref);
        this.iconView = ref;
      }
    };
  }
  render() {
    return <NativeAdIconView {...this.props} ref={this.handleAdIconViewRef}/>;
  }
}
export default class AdIconView extends React.Component {
  render() {
    return (<AdIconViewContext.Consumer>
      {(contextValue) => (<AdIconViewChild {...this.props} {...contextValue}/>)}
    </AdIconViewContext.Consumer>);
  }
}
