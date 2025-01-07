import express from "express"
import { completedTasks, createTask, deleteTask, getTasks, pendingTasks, updateStatus, updateTask } from "../controllers/taskController.js"
import authenticate from "./../services/authMiddleware.js"
import multer from "multer"

const taskRouter = express.Router()

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

taskRouter.post("/task/create", authenticate, upload.single("voice"), createTask)
taskRouter.post("/task/delete", authenticate, deleteTask)
taskRouter.post("/task/update/:taskId", authenticate, updateTask)
taskRouter.get("/task/all", authenticate, getTasks)
taskRouter.get("/task/pending", authenticate, pendingTasks)
taskRouter.get("/task/completed", authenticate, completedTasks)
taskRouter.post('/task/updateStatus/:taskId', authenticate, updateStatus)
taskRouter.get("/task/voice/:taskId", async (req, res) => {
    try {
        const { taskId } = req.params;
        const task = await Task.findByPk(taskId);

        if (!task || !task.voice) {
            return res.status(404).json({ message: "Voice file not found" });
        }

        res.sendFile(task.voice);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error retrieving voice file" });
    }
});


export default taskRouter