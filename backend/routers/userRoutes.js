import express from "express";
import { body } from "express-validator";
import {signUp, login, userInf} from "../controllers/userController.js"
import path from "path"
import multer from "multer";

const userRouter = express.Router()

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, "../profiles"))
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname)
    }
})

const upload = multer({ storage })

userRouter.post("/signup", upload.single("image"), signUp)
userRouter.post("/login", login)
userRouter.post("/userData", userInf)

export default userRouter