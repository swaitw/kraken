import { EventTarget } from './document/event-target';
import { krakenWindow } from './bridge';
import { WINDOW } from './document/event-target';

const windowBuildInEvents = ['load', 'colorschemechange', 'unhandledrejection', 'error'];

// window is global object, which is created by JSEngine,
// This is an extension which add more methods to global window object.
class WindowExtension extends EventTarget {
  constructor() {
    super(WINDOW, windowBuildInEvents);
  }

  public get colorScheme(): string {
    return krakenWindow.colorScheme;
  }

  public get devicePixelRatio() : number {
    return krakenWindow.devicePixelRatio;
  }

  public get window() {
    return this;
  }

  public get parent() {
    return this;
  }
}

export const windowExtension = new WindowExtension();
let propertyEvents = {};
windowBuildInEvents.forEach(event => {
  let eventName = 'on' + event.toLowerCase();
  propertyEvents[eventName] = {
    get() {
      return windowExtension[eventName];
    },
    set(fn: EventListener) {
      windowExtension[eventName] = fn;
    }
  };
});

Object.defineProperties(window, {
  ...propertyEvents,
  addEventListener: {
    get() {
      return windowExtension.addEventListener.bind(windowExtension);
    }
  },
  removeEventListener: {
    get() {
      return windowExtension.removeEventListener.bind(windowExtension);
    }
  },
  dispatchEvent: {
    get() {
      return windowExtension.dispatchEvent.bind(windowExtension);
    }
  },
  __clearListeners__: {
    get() { return windowExtension.__clearListeners__.bind(windowExtension); }
  }
});
