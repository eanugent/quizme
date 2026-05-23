/* eslint no-console: 0 */
import Vue from 'vue'
import Vuetify from 'vuetify'
import ActionCableVue from 'actioncable-vue'
import App from '../app.vue'

Vue.use(Vuetify);

Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: "error",
  connectionUrl: () => {
    `wss://${window.location.host}/cable`
  },
  connectImmediately: true
});

const vuetify = new Vuetify({
  theme: {
    dark: true,
    themes: {
      dark: {
        primary: '#FACC15',
        secondary: '#A78BFA',
        accent: '#F472B6',
        info: '#60A5FA',
        success: '#34D399',
        warning: '#FBBF24',
        error: '#F87171',
        background: '#0B0A1F'
      },
      light: {
        primary: '#6D28D9',
        secondary: '#A78BFA',
        accent: '#F59E0B',
        info: '#3B82F6',
        success: '#10B981',
        warning: '#F59E0B',
        error: '#EF4444'
      }
    },
    options: {
      customProperties: true
    }
  }
});

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    vuetify,
    render: h => h(App)
  }).$mount()
  document.body.appendChild(app.$el)
})
