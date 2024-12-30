import bcrypt from "bcrypt"
import jwt from "jsonwebtoken"
import { validationResult } from "express-validator"
import userModel from "../models/UserModel.js";

const JWT_SECRET = process.env.JWT_SECRET;

// Token
const createTok =  (id) => {
    return jwt.sign(
        { id },
        JWT_SECRET,
        {expiresIn: "1h" }
    )
}

// User SignUp
export const signUp = async (req,res) => {
    const { name, email, password, phone, dateBirth} = req.body;

    const [d, m, y] = dateBirth.split("/");
    const formattedDate = `${y}-${m.padStart(2, "0")}-${d.padStart(2, "0")}`;
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    if (!password) {
      return res.status(400).json({ message: "Password is required" });
    }

    try {
        const exist = await userModel.findOne({ where: {email} });
        
        if (exist) {
            return res.status(400).json({message: "User Already Exists"});
        }
          
        const hashedPassword = await bcrypt.hash(password,12);
        

        let imagePath = null;
    
        if (req.file) {
            imagePath = req.file.path;
        }
        const newUser = await userModel.create({
            name,
            date_birth:formattedDate,
            email,
            password:hashedPassword,
            phone_number:phone,
            image: imagePath
        })
        
        const user = await newUser.save()
        const token = createTok(user.userId)
        
        res.status(201).json({message: 'User created successfully', token });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error In User Controller' });
    }
}

// User Login
export const login = async (req,res) => {
    const {email, password} = req.body;
    
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const user = await userModel.findOne({ where: { email } });

        if (!user) {
            return res.status(400).json({ message: "User Doesn't Exists"});
        }
        
        const isMatch = await bcrypt.compare(password,user.password);
        
        
        if (!isMatch) {
            return res.status(400).json({ message: "Invalid"});
        }
        
        const token = createTok(user.userId)

        res.status(201).json({ token });

    } catch (error) {
        res.json({ message: "Error In User Controller"});
    }
}


export const userInf = async (req, res) => {
    const {token} = req.body;

    try {
            const decoded = jwt.verify(token,process.env.JWT_SECRET);
            const userId = decoded.id;
            console.log(userId);
            
            const user = await userModel.findOne({ where: { userId } });

            if (!user) {
                return res.status(400).json({ message: "User Doesn't Exist" });
            }
    
        res.status(200).json({
            data:{
                userId: user.userId,
                name: user.name,
                date_birth: user.date_birth,
                email: user.email,
                password: user.password,
                phoneNumber: user.phoneNumber,}
        });
        
    } catch (error) {
        res.json({ message: "Error In User Controller"});
    }
}
