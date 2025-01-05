import { DataTypes} from "sequelize";
import sequelize from "../config/db.js";
import userModel from "./UserModel.js";

const taskModel = sequelize.define("Task",{
    task_id:{
        type:DataTypes.INTEGER,
        autoIncrement:true,
        primaryKey:true,
    },
    title:{
        type:DataTypes.STRING,
        allowNull:false,
    },
    description:{
        type:DataTypes.STRING,
        allowNull:true,
    },
    start_date:{
        type:DataTypes.DATE,
        defaultValue:DataTypes.NOW
    },
    end_date:{
        type:DataTypes.DATE,
        allowNull:true
    },
    status:{
        type:DataTypes.ENUM("Pending","Completed"),
        defaultValue:"Pending"
    },
    priority:{
        type:DataTypes.ENUM("Low","Medium","High","Urgent"),
        allowNull:true
    },
    voice:{
        type:DataTypes.STRING,
        allowNull:true
    },
    category:{
        type: DataTypes.STRING,
        allowNull: true
    },
    user_id: {
        type: DataTypes.INTEGER,
        references: {
            model: "User",
            key: "userId",
        },
        allowNull: false,
    }
},{
    tableName:"Task",
    timestamps:true,
    underscored:true,
})

taskModel.associate = (models) => {
    taskModel.belongsTo(models.User, { foreignKey: "userId", onDelete: "CASCADE" });
};

export default taskModel;
