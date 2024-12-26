import express from "express"
import { createTask, deleteTask, getTasks, updateTask } from "../controllers/taskController.js"
import authenticate from "./../services/authMiddleware.js"

const taskRouter = express.Router()

taskRouter.post("/task/create", authenticate, createTask)
taskRouter.post("/task/delete", authenticate, deleteTask)
taskRouter.post("/task/update", authenticate, updateTask)
taskRouter.get("/task/all", authenticate, getTasks)

export default taskRouter