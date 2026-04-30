import { Candidate } from '../../domain/models/Candidate';
import { validateCandidateData } from '../validator';

export const addCandidate = async (candidateData: any) => {
    try {
        validateCandidateData(candidateData);
    } catch (error: any) {
        throw new Error(error);
    }

    const candidate = new Candidate(candidateData);
    try {
        const savedCandidate = await candidate.save();
        return savedCandidate;
    } catch (error: any) {
        if (error.code === 'P2002') {
            throw new Error('The email already exists in the database');
        } else {
            throw error;
        }
    }
};

export const getCandidateById = async (id: number): Promise<Candidate | null> => {
    try {
        const candidate = await Candidate.findOne(id);
        return candidate;
    } catch (error: any) {
        throw new Error('Database connection error');
    }
};
