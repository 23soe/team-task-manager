import axios from "axios";

// Axiosの基本インスタンスを作成
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL, 
    headers: {
      'Content-Type': 'application/json'
    }
})

// リクエスト送信前にトークンを自動で付与
api.interceptors.request.use(config => {
    const token = localStorage.getItem("token")
    if (token) {
        config.headers.Authorization = `Bearer ${token}`
    }
    return config
},error => {
    return Promise.reject(error)
})

export default api