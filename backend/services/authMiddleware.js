import jwt from "jsonwebtoken";
import dotenv from "dotenv";
dotenv.config()

const JWT_SECRET = process.env.JWT_SECRET;

const authenticate = (req, res, next) => {
    
    const token = req.header("token")?.replace("Bearer ","");
    
    
    if (!token) {
        return res.status(401).json({ message: 'No token, authorization denied' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);

        req.user = decoded;
        
        next();
        
    } catch (error) {
        return res.status(401).json({ message: 'Invalid Token' });
    }
}

export default authenticate;