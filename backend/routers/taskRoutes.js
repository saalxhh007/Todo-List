import express from "express"
import { completedTasks, createTask, deleteTask, getTasks, pendingTasks, updateStatus, updateTask } from "../controllers/taskController.js"
import authenticate from "./../services/authMiddleware.js"

const taskRouter = express.Router()

taskRouter.post("/task/create", authenticate, createTask)
taskRouter.post("/task/delete", authenticate, deleteTask)
taskRouter.post("/task/update", authenticate, updateTask)
taskRouter.get("/task/all", authenticate, getTasks)
taskRouter.get("/task/pending", authenticate, pendingTasks)
taskRouter.get("/task/completed", authenticate, completedTasks)
taskRouter.post('/task/updateStatus', authenticate, updateStatus)

export default taskRouter