<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import TaskCard from '@/components/TaskCard.vue'
import api from '@/plugins/axios'
import TeamProgressList from '@/components/TeamProgressList.vue'

const workspaces = ref([])
const selectedWorkspace = ref(null) // 選択されたワークスペース

onMounted(async () => {
  try {
    const response = await api.get(`${import.meta.env.VITE_API_URL}/workspaces`)
    console.log('ワークスペースAPIレスポンス', response) 
    workspaces.value = response.data.workspace
    if (workspaces.value.length > 0) {
      selectedWorkspace.value = workspaces.value[0]
      await fetchTasksByWorkspace(selectedWorkspace.value.id)
      await fetchWorkspaceDetail(selectedWorkspace.value.id)
    }
  } catch (error) {
    console.error('ワークスペース取得エラー', error)
  }
})

const tasks = ref([]) // タスク一覧

const fetchTasksByWorkspace = async (workspaceId) => {
  console.log('Fetch tasks for workspace:', workspaceId)
  try {
    const response = await api.get(`${import.meta.env.VITE_API_URL}/api/v1/workspaces/${workspaceId}/tasks`)
    tasks.value = response.data
  }catch (error) {
    console.error('タスク取得エラー', error)
    tasks.value = [] // エラー時は空の配列にする
  }
}

const fetchWorkspaceDetail = async (workspaceId) => {
  try {
    const response = await api.get(`${import.meta.env.VITE_API_URL}/api/v1/workspaces/${workspaceId}`)
    console.log('ワークスペース詳細取得レスポンス', response.data) // ← 꼭 찍어보기
    selectedWorkspace.value = response.data
  } catch (error) {
    console.error('ワークスペース詳細取得エラー', error)
  }
}

const selectWorkspace = (workspace) => {
  selectedWorkspace.value = workspace
  fetchTasksByWorkspace(workspace.id)
  fetchWorkspaceDetail(workspace.id)
}

const selectedWorkspaceUsers = computed(() => {
  return selectedWorkspace.value?.users || []
})

const router = useRouter()

const handleLogout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  router.push('/login')
}

const selectedAssignee = ref('')   // 担当者選択
const selectedCategory = ref('')   // カテゴリ選択
const selectedStatus = ref('') // ステータス選択

const isNewTask = ref(false) // 新規タスクフラグ

const editingTask = ref(null) // 編集中のタスク
const isEditModalOpen = ref(false) 

const deletingTask = ref(null) // 削除中のタスク
const isDeleteModalOpen = ref(false)

const startCreate = () => {
  editingTask.value = {
    id: Date.now(), //使用するための一時的なID
    title: '',
    contents: '',
    dueDate: '',
    userIds: [],
    category: '',
    status: '開始前'  // 新規タスクは開始前からスタート
  }
  isNewTask.value = true
  isEditModalOpen.value = true
}

const getAssignees = (userIds) => {
  if (!Array.isArray(userIds)) return ''
  if (!selectedWorkspace.value || !Array.isArray(selectedWorkspace.value.users)) return ''

  return selectedWorkspace.value.users
    .filter(user => userIds.includes(user.id))
    .map(user => user.username)
    .join(', ') || '未担当'
}

const tasksNotStarted = computed(() => {
  if (!tasks.value || !Array.isArray(tasks.value)) return []
  return tasks.value.filter(task => {
    const statusMatch = task.status === '開始前'
    const assigneeMatch = selectedAssignee.value
      ? (Array.isArray(task.user_ids) && task.user_ids.includes(Number(selectedAssignee.value)))
      : true
    const categoryMatch = selectedCategory.value
      ? task.category === selectedCategory.value
      : true
    return statusMatch && assigneeMatch && categoryMatch
  })
})
const tasksInProgress = computed(() => {
  if (!tasks.value || !Array.isArray(tasks.value)) return []
  return tasks.value.filter(task => {
    const statusMatch = task.status === '進行中'
    const assigneeMatch = selectedAssignee.value
      ? (Array.isArray(task.user_ids) && task.user_ids.includes(Number(selectedAssignee.value)))
      : true
    const categoryMatch = selectedCategory.value
      ? task.category === selectedCategory.value
      : true
    return statusMatch && assigneeMatch && categoryMatch
  })
})
const tasksCompleted = computed(() => {
  if (!tasks.value || !Array.isArray(tasks.value)) return []
  return tasks.value.filter(task => {
    const statusMatch = task.status === '完了'
    const assigneeMatch = selectedAssignee.value
      ? (Array.isArray(task.user_ids) && task.user_ids.includes(Number(selectedAssignee.value)))
      : true
    const categoryMatch = selectedCategory.value
      ? task.category === selectedCategory.value
      : true
    return statusMatch && assigneeMatch && categoryMatch
  })
})

const toggleStatus = async (task) => {
  if (task.status === '開始前') {
    task.status = '進行中'
  } else if (task.status === '進行中') {
    task.status = '完了'
  }
  try {
    await api.put(`${import.meta.env.VITE_API_URL}/api/v1/tasks/${task.id}`, task)
    console.log('状態変更API成功:', task)
  } catch (error) {
    console.error('状態変更APIエラー', error)
    alert('ステータス更新に失敗しました。')
  }
}

const nextStatusText = (task) => {
  if (task.status === '開始前') {
    return '開始前'
  } else if (task.status === '進行中') {
    return '進行中'
  } else {
    return '完了'
  }
}

const requestDelete = (task) => {
  deletingTask.value = task
  isDeleteModalOpen.value = true
}

const confirmDelete = async () => {
  if (deletingTask.value) {
    try{
      await api.delete(`${import.meta.env.VITE_API_URL}/api/v1/tasks/${deletingTask.value.id}`)
      tasks.value = tasks.value.filter(t => t.id !== deletingTask.value.id)
      deletingTask.value = null
      isDeleteModalOpen.value = false
    } catch (error) {
      console.error('タスク削除エラー', error)
    } finally {
      if (isDeleteModalOpen.value !== null){
        isDeleteModalOpen.value = false
      }
      deletingTask.value = null
    }
  }
}

const cancleDelete = () => {
  isDeleteModalOpen.value = false
  deletingTask.value = null
}
    
const startEdit = (task) => {
  editingTask.value = { 
    ...task,
    userIds: Array.isArray(task.userIds) ? [...task.userIds] : [] 
  } 
  isNewTask.value = false
  isEditModalOpen.value = true
}

const saveEdit = async () => {
  try {
    const payload = {
      title: editingTask.value.title,
      contents: editingTask.value.contents,
      due_date: editingTask.value.dueDate,  
      status: editingTask.value.status,
      category: editingTask.value.category,
      user_ids: editingTask.value.userIds
    }

    if (isNewTask.value) {
      const response = await api.post(
        `${import.meta.env.VITE_API_URL}/api/v1/workspaces/${selectedWorkspace.value.id}/tasks`,
        payload
      )
      tasks.value.push(response.data)
    } else {
      const response = await api.put(
        `${import.meta.env.VITE_API_URL}/api/v1/tasks/${editingTask.value.id}`,
        payload
      )
      const index = tasks.value.findIndex(t => t.id === editingTask.value.id)
      if (index !== -1) {
        tasks.value[index] = response.data
      }
    }
  } catch (error) {
    console.error('タスク保存エラー', error)
    alert('タスクの保存に失敗しました。')
  } finally {
    if (isEditModalOpen.value !== null) {
      isEditModalOpen.value = false
    }
    editingTask.value = null
  }
}

const cancelEdit = () => {
  isEditModalOpen.value = false
  editingTask.value = null
}

</script>

<template>
  <div class="workspace-container">
    <div class="workspace-selector">
      <div class="workspace-buttons">
        <button 
          v-for="workspace in workspaces" 
          :key="workspace.id" 
          :class="['workspace-button', { active: selectedWorkspace?.id === workspace.id }]"
          @click="selectWorkspace(workspace)"
        >
          {{ workspace.name }}
        </button>
      </div> <!-- /.workspace-buttons -->
    </div> <!-- /.workspace-selector -->
    <TeamProgressList
      v-if="selectedWorkspace"
      :workspace-id="selectedWorkspace.id"
    />
    <div class="task-list-view">
      <button @click="handleLogout" class="logout-button">ログアウト</button>
      <h1>タスク一覧画面</h1>

      <div class="filters">
        <label>
          ⭐担当者
          <select v-model="selectedAssignee">
            <option value="">全て</option>
            <option 
              v-for="user in selectedWorkspaceUsers" 
              :key="user.id" 
              :value="user.id"
            >
              {{ user.username }}
            </option>
          </select>
        </label>
        <label>
          ⭐カテゴリ:
          <select v-model="selectedCategory">
            <option value="">全て</option>
            <option value="カテゴリ1">カテゴリ1</option>
            <option value="カテゴリ2">カテゴリ2</option>
            <option value="カテゴリ3">カテゴリ3</option>
          </select>
        </label>
      </div> <!-- /.filters -->

      <div class="task-section">
        <section class="task-status-section">
          <h2>⏳ 開始前</h2>
          <TaskCard 
            v-for="task in tasksNotStarted" 
            :key="task.id" 
            :task="{
              ...task,
              dueDate: task.due_date, // 🛠️ Snake -> Camel
              userIds: task.user_ids
            }"
            :toggleStatus="toggleStatus"
            :getAssignees="getAssignees"
            @edit="startEdit"
            @request-delete="requestDelete"
          />
          <button @click="startCreate" class="create-button">➕</button>
        </section>

        <section class="task-status-section">
          <h2>🚀 進行中</h2>
          <TaskCard 
            v-for="task in tasksInProgress" 
            :key="task.id" 
            :task="{
              ...task,
              dueDate: task.due_date, // 🛠️ Snake -> Camel
              userIds: task.user_ids
            }"
            :toggleStatus="toggleStatus"
            :getAssignees="getAssignees"
            @edit="startEdit"
            @request-delete="requestDelete"
          />
        </section>

        <section class="task-status-section">
          <h2>✅ 完了</h2>
          <TaskCard 
            v-for="task in tasksCompleted" 
            :key="task.id" 
            :task="{
              ...task,
              dueDate: task.due_date, // 🛠️ Snake -> Camel
              userIds: task.user_ids
            }"
            :toggleStatus="toggleStatus"
            :getAssignees="getAssignees"
            @edit="startEdit"
            @request-delete="requestDelete"
          />
        </section>
      </div> <!-- /.task-section -->
    </div> <!-- /.task-list-view -->

    <div v-if="isDeleteModalOpen" class="modal-overlay">
      <div class="modal-content">
        <h2>⚠️ タスク削除</h2>
        <p>本当にこのタスクを削除しますか？</p>
        <p>タスク名: {{ deletingTask.title }}</p>
        <div class="modal-actions">
          <button @click="confirmDelete">削除</button>
          <button @click="cancleDelete">キャンセル</button>
        </div>
      </div>
    </div>

    <div v-if="isEditModalOpen" class="modal-overlay">
      <div class="modal-content">
        <h2>📝 タスク編集</h2>

        <label>⭐ タイトル:</label>
        <input v-model="editingTask.title" placeholder="タイトル" />

        <label>⭐ 内容:</label>
        <textarea v-model="editingTask.contents" placeholder="内容"></textarea>

        <label>⭐ 締切日:</label>
        <input v-model="editingTask.dueDate" type="date" />

        <label>⭐ 担当者:</label>
        <div class="checkbox-group">
          <label 
            v-for="user in selectedWorkspaceUsers" 
            :key="user.id" 
            class="checkbox-item"
          >
            <input type="checkbox" :value="user.id" v-model="editingTask.userIds" />
            {{ user.username }}
          </label>
        </div>

        <label>⭐ カテゴリ:</label>
        <select v-model="editingTask.category">
          <option value="">選択してください</option>
          <option value="カテゴリ1">カテゴリ1</option>
          <option value="カテゴリ2">カテゴリ2</option>
          <option value="カテゴリ3">カテゴリ3</option>
        </select>

        <div class="modal-actions">
          <button @click="saveEdit">保存</button>
          <button @click="cancelEdit">キャンセル</button>
        </div>
      </div>
    </div>

  </div> <!-- /.workspace-container -->
</template>


<style scoped>
.workspace-selector {
  position: absolute;
  top: 1vh;
  left: 1vw;
  cursor: pointer;
  display: flex;
}

.workspace-buttons {
  display: flex;
  flex-direction: row;
  gap: 2vh;
}

.workspace-button.active {
  background: #646cff;
}

.task-list-view {
  flex-grow: 1;
}

.logout-button{
  position: absolute;
  top: 1vh;
  right:1vw;
  cursor: pointer;
}
.logout-button:hover {
  border-color:rgb(241, 0, 0);
  color: rgb(241, 0, 0);
}

.create-button {
  width: 100%;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-size: 16px;
}

.task-section {
  margin: 0 atuo;
  display: flex;
  justify-content: center; 
  gap:1vw;
}

.task-status-section {
  width: 28vw; 
  min-width: 250px; 
  padding: 10px;
  border-radius: 8px;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  display: flex;
  flex-direction: column;
  background: black;
  padding: 30px;
  border-radius: 10px;
  width: 400px;
  max-width: 90%;
}

.modal-actions {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
}

.checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.checkbox-item {
  display: flex;
  align-items: center;
}

</style>
