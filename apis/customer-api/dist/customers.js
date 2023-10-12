"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const customer_data_1 = require("./customer-data");
const getCustomerDetails = async (customerNumber, res) => {
    const customer = customer_data_1.customers.find(a => a.customerNumber === customerNumber);
    if (customer !== undefined) {
        console.log(`Returning customer ${customerNumber}`);
        return res.send(customer);
    }
    console.log(`Could not find customer ${customerNumber}`);
    res.sendStatus(404);
};
exports.default = { getCustomerDetails };
//# sourceMappingURL=customers.js.map