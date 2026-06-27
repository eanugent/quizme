import Vue from 'vue'
import Vuetify from 'vuetify'
import VueRouter from 'vue-router'
import AdminApp from '../admin.vue'

Vue.use(Vuetify)
Vue.use(VueRouter)

const routes = [
  {
    path: '/admin/login',
    name: 'login',
    component: () => import('./components/admin/admin-login.vue'),
    meta: { guest: true }
  },
  {
    path: '/admin',
    component: () => import('./components/admin/admin-layout.vue'),
    children: [
      { path: '', redirect: 'characters' },
      {
        path: 'characters',
        name: 'characters',
        component: () => import('./components/admin/manage-characters.vue')
      }
    ]
  }
]

const router = new VueRouter({
  mode: 'history',
  routes
})

router.beforeEach(async (to, from, next) => {
  const adminApi = (await import('./admin-api')).default
  let authenticated = false

  try {
    const response = await adminApi.get('/admin/session')
    authenticated = response.data.authenticated
  } catch (_error) {
    authenticated = false
  }

  if (to.matched.some(record => record.meta.guest)) {
    next(authenticated ? '/admin/characters' : undefined)
    return
  }

  if (!authenticated) {
    next('/admin/login')
    return
  }

  next()
})

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
      }
    }
  }
})

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    router,
    vuetify,
    render: h => h(AdminApp)
  }).$mount()
  document.body.appendChild(app.$el)
})
