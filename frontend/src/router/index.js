import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '@/views/LoginView.vue'
import SignupView from '@/views/SignupView.vue'
import TaskListView from '@/views/TaskListView.vue'

const routes = [
    { path: '/', redirect: '/login' },
    { path: '/login', component: LoginView },
    { path: '/signup', component: SignupView },
    { path: '/tasks', component: TaskListView, meta: { requiresAuth: true } }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// Navigation Guard 設定
router.beforeEach((to, from, next) => {
    const token = localStorage.getItem('token')

    if (to.meta.requiresAuth && !token) {
        next('/login') // tokenがない場合はログインページへリダイレクト
    }else{
        next() // tokenがある場合はそのまま進む
    }
})

export default router