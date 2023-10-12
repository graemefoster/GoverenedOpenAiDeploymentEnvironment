export interface Customer {
    id: number
    customerNumber: string
    name: string
}
export const customers: Customer[] = [
    {
        id: 1,
        customerNumber: '11111111',
        name: 'Graeme'
    },
    {
        id: 2,
        customerNumber: '22222222',
        name: 'Alice'
    },
    {
        id: 3,
        customerNumber: '33333333',
        name: 'Oliver'
    }
]
