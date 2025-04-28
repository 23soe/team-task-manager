<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const name = ref('')
const selectedOrganizations  = ref([])
const organizationOptions = ref([])
const email = ref('')
const password = ref('')
const password_confirmation = ref('')

onMounted(async () => {
    try {
        const response = await axios.get(`${import.meta.env.VITE_API_URL}/organizations`)
        organizationOptions.value = response.data
    } catch (error) {
        console.error('組織の取得に失敗', error)
    }
})

const handleSignup = async () => {

    if (password.value !== password_confirmation.value) {
        alert('パスワードとパスワード確認が一致していません。')
        return
    }
    try{
        const response = await axios.post(`${import.meta.env.VITE_API_URL}/signup`, {
            user: {
                username: name.value,
                email: email.value,
                password: password.value,
                password_confirmation: password_confirmation.value,
            },
            organization_names: selectedOrganizations.value
        })
        console.log('サインアップ成功!', response.data)
        alert('登録が成功しました！')
        router.push('/login')
    } catch (error) {
        console.error('サインアップ失敗', error.response?.data)
        alert('登録に失敗しました。')
    }
}
</script>

<template>
    <div class="signup-vie">
        <h1>Sign up</h1>
        <form @submit.prevent="handleSignup">
            <input v-model="name" type="text" placeholder="名前" required/>
            <input v-model="email" type="email" placeholder="メールアドレス" required/>
            <input v-model="password" type="password" placeholder="パスワード" required/>
            <input v-model="password_confirmation" type="password" placeholder="パスワード確認" required/>
            <div class="signup-organiztion">
                <div v-for="org in organizationOptions" :key="org">
                    <label>
                        <input type="checkbox" :value="org.name" v-model="selectedOrganizations" />
                        {{ org.name }}
                    </label>
                </div>
            </div>
            <button type="submit">サインアップ</button>
        </form>
    </div>
</template>

<style scoped>
.signup-organiztion {
    display: flex;
    flex-direction: row;
    gap: 20px;
    justify-content: center; 
}
</style>