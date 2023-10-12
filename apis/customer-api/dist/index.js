"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const customers_1 = __importDefault(require("./customers"));
const app = (0, express_1.default)();
app.set('port', process.env.PORT || 3000);
app.use(express_1.default.json());
const router = express_1.default.Router();
router.get('/customer/:customerNumber', (req, res) => customers_1.default.getCustomerDetails(req.params.customerNumber, res));
app.use(router);
app.listen(app.get('port'));
console.log(`listening on port ${app.get('port')}`);
//# sourceMappingURL=index.js.map