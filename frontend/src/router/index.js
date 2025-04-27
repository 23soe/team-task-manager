import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '@/views/LoginView.vue'
import SignupView from '@/views/SignupView.vue'
import TaskListView from '@/views/TaskListView.vue'

const routes = [
    { path: '/', redirect: '/login' },
    { path: '/login', component: LoginView },
    { path: '/signup', component: SignupView },
    { path: '/tasks', component: TaskListView },
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router