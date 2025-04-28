<script setup>
import { ref, onMounted } from 'vue'
import api from '@/plugins/axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('')
const password = ref('')

onMounted(() => {
    const token = localStorage.getItem('token')
    if (token) {
        router.push('/tasks')
    }
})

const handleLogin = async () => {
    try {
        const response = await api.post(`${import.meta.env.VITE_API_URL}/login`, {
            email: email.value,
            password: password.value,
        })
        const { token, user } = response.data

        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))

        alert('ログイン成功！')
        router.push('/tasks')
    }catch (error) {
    console.error(error)

    if (error.response) {
      console.log(error.response.data)
      alert(`ログイン失敗: ${error.response.data.errors?.[0] || 'エラー'}`)
    } else {
      alert('ログイン失敗（サーバーに接続できません）')
    }
  }
}
</script>

<template>
    <div class="login-view">
        <h1>Login</h1>
        <form @submit.prevent="handleLogin">
            <input v-model="email" type="email" placeholder="メールアドレス" required />
            <input v-model="password" type="password" placeholder="パスワード " required />
            <button type="submit" class="login-button">ログイン</button>
            <router-link to="/signup" class="signup-button">
                サインアップ
            </router-link>
        </form>
    </div>
</template>

<style scoped>
.login-button {
  display: inline-block;
  padding: 10px 20px;
  background-color: #4CAF50;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  text-align: center;
}
.signup-button {
  display: inline-block;
  padding: 10px 20px;
  background-color: #1a1a1a;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  text-align: center;
}
</style>