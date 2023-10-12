import { Response } from 'express';
import { Customer, customers } from './customer-data'

const getCustomerDetails = async (customerNumber: string, res: Response) => {
    const customer = customers.find(a => a.customerNumber === customerNumber);
    if (customer !== undefined) {
        console.log(`Returning customer ${customerNumber}`)
        return res.send(customer);
    }
    console.log(`Could not find customer ${customerNumber}`)
    res.sendStatus(404);
}

export default { getCustomerDetails }
