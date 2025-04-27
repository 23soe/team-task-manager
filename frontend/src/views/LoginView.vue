<script setup>
import { ref } from 'vue'

const email = ref('')
const password = ref('')

const handleLogin = () => {
    console.log('ログインボタンclick!', email.value, password.value)
    //以降、Axiosでバックエンドにログイン要求を送信
}
</script>

<template>
    <div class="login-view">
        <h1>Login</h1>
        <form @submit.prevent="handleLogin">
            <input v-model="email" type="email" placeholder="メールアドレス" required />
            <input v-model="password" type="password" placeholder="パスワード" required />
            <button type="submit">ログイン</button>
        </form>
    </div>
</template>

<style scoped>
</style>