import express from 'express';
import syncDatabase from './models/relations.js';
import userRouter from './routers/userRoutes.js';
import taskRouter from './routers/taskRoutes.js';
import cors from "cors"
import bodyParser from 'body-parser';

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(cors())
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
syncDatabase()

app.use("/", userRouter)
app.use("/", taskRouter)


app.get('/', (req, res) => {
  res.send('Hello, World!');
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
