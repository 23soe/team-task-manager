<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/plugins/axios'

import TeamProgressList from '@/components/TeamProgressList.vue'
import TaskCard from '@/components/TaskCard.vue'
import EditTaskModal from '@/components/EditTaskModal.vue'

const workspaces = ref([])
const selectedWorkspace = ref(null) // 選択されたワークスペース

const membersProgress = ref([]) // チームメンバーの進捗情報
const fetchMembersProgress = async () => {
  try {
    const res = await api.get(`${import.meta.env.VITE_API_URL}/api/v1/task_progresses`, {
      params: {
        workspace_id: selectedWorkspace.value.id
      }
    })
    membersProgress.value = res.data
  } catch (error) {
    console.error('進捗一覧の取得に失敗しました', error)
  }
}

onMounted(async () => {
  try {
    const response = await api.get(`${import.meta.env.VITE_API_URL}/workspaces`)
    console.log('ワークスペースAPIレスポンス', response) 
    workspaces.value = response.data.workspace
    if (workspaces.value.length > 0) {
      selectedWorkspace.value = workspaces.value[0]
      await fetchTasksByWorkspace(selectedWorkspace.value.id)
      await fetchWorkspaceDetail(selectedWorkspace.value.id)
      await fetchMembersProgress()
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
    console.log('ワークスペース詳細取得レスポンス', response.data) 
    selectedWorkspace.value = response.data
  } catch (error) {
    console.error('ワークスペース詳細取得エラー', error)
  }
}

const selectWorkspace = (workspace) => {
  selectedWorkspace.value = workspace
  fetchTasksByWorkspace(workspace.id)
  fetchWorkspaceDetail(workspace.id)
  fetchMembersProgress()
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

const filteredTasksByStatus = (status) => {
  if (!tasks.value || !Array.isArray(tasks.value)) return []
  return tasks.value.filter(task => {
    const statusMatch = task.status === status
    const assigneeMatch = selectedAssignee.value
      ? Array.isArray(task.user_ids) && task.user_ids.includes(Number(selectedAssignee.value))
      : true
    const categoryMatch = selectedCategory.value
      ? task.category === selectedCategory.value
      : true
    return statusMatch && assigneeMatch && categoryMatch
  })
}

const tasksNotStarted = computed(() => filteredTasksByStatus('開始前'))
const tasksInProgress = computed(() => filteredTasksByStatus('進行中'))
const tasksCompleted = computed(() => filteredTasksByStatus('完了'))

// ✅ 状態を次に進めるユーティリティ
const getNextStatus = (currentStatus) => {
  switch (currentStatus) {
    case '開始前':
      return '進行中'
    case '進行中':
      return '完了'
    default:
      return '完了'
  }
}

// ✅ 状態変更ロジック（UI先行反映）
const toggleStatus = async (task) => {
  const previousStatus = task.status
  task.status = getNextStatus(task.status)

  try {
    await api.put(`${import.meta.env.VITE_API_URL}/api/v1/tasks/${task.id}`, task)
    console.log('状態変更API成功:', task)

    await fetchTasksByWorkspace(selectedWorkspace.value.id)
  } catch (error) {
    console.error('状態変更APIエラー', error)
    alert('ステータス更新に失敗しました。')
    task.status = previousStatus
  }
}

const requestDelete = (task) => {
  deletingTask.value = task
  isDeleteModalOpen.value = true
}

const confirmDelete = async () => {
  isDeleteModalOpen.value = false
  if (deletingTask.value) {
    try{
      await api.delete(`${import.meta.env.VITE_API_URL}/api/v1/tasks/${deletingTask.value.id}`)
      tasks.value = tasks.value.filter(t => t.id !== deletingTask.value.id)

      deletingTask.value = null
      isDeleteModalOpen.value = false
    } catch (error) {
      console.error('タスク削除エラー', error)
    } finally {
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
  isEditModalOpen.value = false
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
    isEditModalOpen.value = open
  } finally {
    editingTask.value = null
  }
}

const cancelEdit = () => {
  isEditModalOpen.value = false
  editingTask.value = null
}

const lastUpdated = ref(null)

const recalculateProgress = async () => {
  try{
    await api.post(`${import.meta.env.VITE_API_URL}/api/v1/task_progresses/recalculate`, {
      workspace_id: selectedWorkspace.value.id
    })
    await fetchMembersProgress()
    lastUpdated.value = new Date()
    alert('進捗を更新しました ✅')
  }catch(error){
    console.error('進捗再集計エラー', error)
    alert('進捗の再集計に失敗しました。')
  }
}

const taskSections = computed(() => [
  { label: '⏳ 開始前', tasks: tasksNotStarted.value },
  { label: '🚀 進行中', tasks: tasksInProgress.value },
  { label: '✅ 完了', tasks: tasksCompleted.value },
])

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
      :members-progress="membersProgress"
    />

    <div class="progress-update-control">
      <button @click="recalculateProgress" class="recalc-button">🔄 進捗を再集計</button>
    </div>
    <button @click="handleLogout" class="logout-button">ログアウト</button>
    <div class="task-list-view">
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
        <section
          v-for="(section, i) in taskSections"
          :key="i"
          class="task-status-section"
        >
          <h2>{{ section.label }}</h2>
          <TaskCard
            v-for="task in section.tasks"
            :key="task.id"
            :task="{
              ...task,
              dueDate: task.due_date,
              userIds: task.user_ids
            }"
            :toggleStatus="toggleStatus"
            :getAssignees="getAssignees"
            @edit="startEdit"
            @request-delete="requestDelete"
          />
          <button
            v-if="i === 0"
            @click="startCreate"
            class="create-button"
          >
            ➕
          </button>
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

    <EditTaskModal
      :task="editingTask"
      :users="selectedWorkspaceUsers"
      :visible="isEditModalOpen"
      @save="saveEdit"
      @cancel="cancelEdit"
    />

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

.progress-update-control{
  display:flex;
  justify-content: flex-end
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

.recalc-button {
  margin: 1vh;
  padding: 0.5vh 0.5vw;
  border: none;
  cursor: pointer;
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
  padding: 3vh;
  border-radius: 10px;
  width: 50vw;
  max-width: 90%;
  text-align:left;
  gap: 5px; 
}

.modal-actions {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
}
</style>
