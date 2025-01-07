import sequelize from "../config/db.js";
import { DataTypes } from "sequelize";

const userModel = sequelize.define("User", {
    
    userId:{
        type:DataTypes.INTEGER,
        primaryKey:true,
        autoIncrement:true,
    },
    name:{
        type:DataTypes.STRING,
        allowNull:false
    },
    date_birth:{
        type:DataTypes.DATE,
        allowNull:true,
        defaultValue:null
    },
    email:{
        type:DataTypes.STRING,
        allowNull:false
    },
    password:{
        type:DataTypes.STRING,
        allowNull:false
    },
    phoneNumber:{
        type:DataTypes.STRING,
        allowNull:true
    },
    createdAt:{
        type:DataTypes.DATE,
        allowNull:true
    },
    updatedAt:{
        type:DataTypes.DATE,
        allowNull:true
    }
},{
    tableName:"User",
    timestamps:true,
    underscored:true,
})

userModel.associate = (models) => {
    userModel.hasMany(models.Task, { foreignKey: "userId", onDelete: "CASCADE" });
};

export default userModel;