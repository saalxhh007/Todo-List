import { DataTypes} from "sequelize";
import sequelize from "../config/db.js";
import userModel from "./UserModel.js";

const taskModel = sequelize.define("Task",{
    taskId:{
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
    startDate:{
        type:DataTypes.DATE,
        defaultValue:DataTypes.NOW
    },
    endDate:{
        type:DataTypes.DATE,
        allowNull:true
    },
    status:{
        type:DataTypes.ENUM("Pending","Completed"),
        defaultValue:"Pending"
    },
    periority:{
        type:DataTypes.ENUM("Low","Medium","High","Urgent"),
        allowNull:true
    },
    Voice:{
        type:DataTypes.STRING,
        allowNull:true
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
