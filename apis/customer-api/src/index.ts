import express from 'express'
import accounts from './customers'


const app = express()

app.set('port', process.env.PORT || 3000);
app.use(express.json())

const router = express.Router()

router.get('/customer/:customerNumber', (req, res) => accounts.getAccountBalance(req.params.accountNumber, res));

app.use(router)
app.listen(app.get('port'))

console.log(`listening on port ${app.get('port')}`)
