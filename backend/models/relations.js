import sequelize from "../config/db.js";
import userModel from "./UserModel.js";
import taskModel from "./taskModel.js";

const models = {
    User:userModel,
    Task:taskModel
}

Object.values(models).forEach((model) => {
    if (model.associate) {
        model.associate(models);
    }
});

const syncDatabase = async () => {
    try {
        await sequelize.sync({ force: false });
        console.log('Database synced successfully!');
    } catch (err) {
        console.error('Error syncing database:', err);
    }
};

export default syncDatabase