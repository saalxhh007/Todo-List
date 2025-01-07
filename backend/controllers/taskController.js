import taskModel from "../models/taskModel.js";

export const createTask = async (req, res) => {

    const { title, description, start_date, end_date, status, priority } = req.body;
    const user_id = req.user.id;
    let voicePath = null;

    if (req.file) {
        const uploadDir = path.join(__dirname, "../uploads/voices/");
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }

        const fileName = `${Date.now()}_${req.file.originalname}`;
        voicePath = path.join(uploadDir, fileName);

        fs.writeFileSync(voicePath, req.file.buffer);
    }
    try {
        const newTask = await taskModel.create({
            title,
            description,
            start_date,
            end_date,
            status,
            priority,
            voice: voicePath,
            user_id,
        });

        res.status(201).json({ data: newTask, message: "Task created successfully"})
        
    } catch (error) {
        console.error("Error creating task:", error);
        res.status(500).json({ success: false, message: error.message });
    }
}

export const deleteTask = async (req, res) => {
    const { taskId } = req.body;
    console.log(taskId);

    try {
        const TaskToDelete = await taskModel.findByPk(taskId);

        if (!TaskToDelete) {
            return res.status(401).json({ success: false, message: "Task not found" });
        }

        await TaskToDelete.destroy();

        return res.status(201).json({ success: true, message: "Task Deleted" });
    } catch (error) {
        console.error("Error in deleteTask:", error);
        return res.status(500).json({ success: false, message: "An error occurred" });
    }
};

export const updateTask = async (req, res) => {
    const { taskId } = req.params;
    console.log(taskId);
    
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
        
        if (tasks.length === 0) {
            return res.status(404).json({ success: false, message: "No Tasks Found" });
        }

        res.status(200).json({ success: true, data: tasks, message: "Tasks retrieved successfully" })

    } catch (error) {
        res.status(500).json({ success: false, message: "Error In Retrieving Tasks" });
    }
}

export const pendingTasks = async (req, res) => {
    try {
        const userId = req.user.id
        const tasks = await taskModel.findAll({
            where: { user_id: userId, status: "Pending" },
        });
        
        if (tasks.length === 0) {
            return res.status(404).json({ success: false, message: "No Tasks Found" });
        }

        res.status(200).json({ success: true, data: tasks, message: "Tasks retrieved successfully" })

    } catch (error) {
        res.status(500).json({ success: false, message: "Error In Retrieving Tasks" });
    }
}

export const completedTasks = async (req, res) => {
    try {
        const userId = req.user.id
        const tasks = await taskModel.findAll({
            where: { user_id: userId, status: "Completed" },
        });
        
        if (tasks.length === 0) {
            return res.status(200).json({ success: false, message: "No Tasks Found" });
        }

        res.status(200).json({ success: true, data: tasks, message: "Tasks retrieved successfully" })

    } catch (error) {
        res.status(500).json({ success: false, message: "Error In Retrieving Tasks" });
    }
}

export const updateStatus = async (req, res) => {
    const { taskId } = req.params;
    const { status } = req.body;
    console.log(req.params);
    console.log(taskId);
    

    try {
        const taskToUpdate = await taskModel.findByPk(taskId);

        if (!taskToUpdate) {
            return res.status(404).json({ success: false, message: "Task not found" });
        }

        await taskToUpdate.update({ status });

        res.status(200).json({ data: taskToUpdate, message: "Task Updated" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
}
