import taskModel from "../models/taskModel.js";

export const createTask = async (req, res) => {

    const { title, description, startDate, endDate, status, periority, voice } = req.body
    
    try {
        const userId = req.user.id;
        

        const newTask = await taskModel.create({
            title,
            description,
            startDate,
            endDate,
            status,
            periority,
            voice,
            userId
        })

        res.status(201).json({ data: newTask, message: "Task created successfully"})
        
    } catch (error) {
        res.status(500).json({ success: false, message: "An error occurred while creating the task"
    });
    }
}

export const deleteTask = async (req, res) => {
    const {taskId}  = req.query;
    
    try {
        const TaskToDelete = await taskModel.findByPk(taskId)

        if (!TaskToDelete) {
            res.status(401).json({ success:false , message:"Task not found" });
        }

        await TaskToDelete.destroy()

        res.status(201).json({success:true , message:"Task Deleted"});

    } catch (error) {
        res.status(401).json({success:false , message:"Task not found"});
    }
}

export const updateTask = async (req, res) => {
    const { taskId } = req.query;
    const updates = req.body;
    
    try {
        const taskToUpdate = await taskModel.findByPk(taskId)

        if (!taskToUpdate) {
            res.status(401).json({ success:false , message:"Task not found" });
        }

        await taskToUpdate.update(updates)

        res.status(201).json({ data:taskToUpdate , message:"Task Updated" });

    } catch (error) {
        res.status(401).json({ success:false , message:error });
        
    }
}

export const getTasks = async (req, res) => {
    try {
        const userId = req.user.id
        const tasks = await taskModel.findAll({ where: { userId } })

        if (!tasks.length) {
            return res.status(404).json({ success: false, message: "No Tasks Found" });
        }

        res.status(200).json({ success: true, data: tasks, message: "Tasks retrieved successfully" })

    } catch (error) {
        res.status(500).json({ success: false, message: "Error In Retrieving Tasks" });
    }
}