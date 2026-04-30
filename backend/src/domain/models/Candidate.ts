import { PrismaClient, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

export class Candidate {
    id?: number;
    firstName: string;
    lastName: string;
    email: string;
    phone?: string;
    address?: string;

    constructor(data: any) {
        this.id = data.id;
        this.firstName = data.firstName;
        this.lastName = data.lastName;
        this.email = data.email;
        this.phone = data.phone;
        this.address = data.address;
    }

    async save() {
        const candidateData: any = {};

        if (this.firstName !== undefined) candidateData.firstName = this.firstName;
        if (this.lastName !== undefined) candidateData.lastName = this.lastName;
        if (this.email !== undefined) candidateData.email = this.email;
        if (this.phone !== undefined) candidateData.phone = this.phone;
        if (this.address !== undefined) candidateData.address = this.address;

        if (this.id) {
            try {
                return await prisma.candidate.update({
                    where: { id: this.id },
                    data: candidateData
                });
            } catch (error: any) {
                console.log(error);
                if (error instanceof Prisma.PrismaClientInitializationError) {
                    throw new Error('No se pudo conectar con la base de datos. Por favor, asegúrese de que el servidor de base de datos esté en ejecución.');
                } else if (error.code === 'P2025') {
                    throw new Error('No se pudo encontrar el registro del candidato con el ID proporcionado.');
                } else {
                    throw error;
                }
            }
        } else {
            try {
                const result = await prisma.candidate.create({
                    data: candidateData
                });
                return result;
            } catch (error: any) {
                if (error instanceof Prisma.PrismaClientInitializationError) {
                    throw new Error('No se pudo conectar con la base de datos. Por favor, asegúrese de que el servidor de base de datos esté en ejecución.');
                } else {
                    throw error;
                }
            }
        }
    }

    static async findOne(id: number): Promise<Candidate | null> {
        const data = await prisma.candidate.findUnique({
            where: { id: id }
        });
        if (!data) return null;
        return new Candidate(data);
    }
}
