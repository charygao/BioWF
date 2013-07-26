using System;
using System.Collections.Generic;
using Bio;
using Bio.IO.FastA;
using Bio.Algorithms.Assembly;
using Bio.Algorithms.Assembly.Padena;
using Bio.Algorithms.Alignment;
using Bio.SimilarityMatrices;
using Bio.Algorithms.Alignment.MultipleSequenceAlignment;

namespace $rootnamespace$.Samples
{
    public static partial class BioUtilities
    {
        /// <summary>
        /// Exports a given sequence to a file in FastA format
        /// </summary>
        /// <param name="sequence">Sequence to be exported.</param>
        /// <param name="filename">Target filename.</param>
        public static void ExportFastA(ISequence sequence, string filename)
        {
            // A formatter to export the output
            FastAFormatter formatter = new FastAFormatter(filename);

            // Exports the sequence to a file
            formatter.Write(sequence);
        }

        /// <summary>
        /// Exports a given list of sequences to a file in FastA format
        /// </summary>
        /// <param name="sequences">List of Sequences to be exported.</param>
        /// <param name="filename">Target filename.</param>
        public static void ExportFastA(ICollection<ISequence> sequences, string filename)
        {
            // A formatter to export the output
            FastAFormatter formatter = new FastAFormatter(filename);

            // Exports the sequences to a file
            formatter.Write(sequences);
        }

        /// <summary>
        /// Parses a FastA file which has one or more sequences.
        /// </summary>
        /// <param name="filename">Path to the file to be parsed.</param>
        /// <returns>ISequence objects</returns>
        public static IEnumerable<ISequence> ParseFastA(string filename)
        {
            // A new parser to import a file
            FastAParser parser = new FastAParser(filename);
            return parser.Parse();
        }

        /// <summary>
        /// Merges two sequence ranges with default parameters.
        /// </summary>
        /// <param name="referenceSequence">Reference sequence for merging.</param>
        /// <param name="querySequence">Query sequence for merging.</param>
        /// <returns>SequenceRangeGrouping with merged output.</returns>
        public static SequenceRangeGrouping DoBEDMerge(SequenceRangeGrouping referenceSequence, SequenceRangeGrouping querySequence)
        {
            return referenceSequence.MergeOverlaps(querySequence);
        }

        /// <summary>
        /// Method to do a denovo assembly.
        /// This sample uses Padena Denovo assembler.
        /// </summary>
        /// <param name="sequences">List of sequences to assemble.</param>
        /// <returns>PadenaAssembly which contain the assembled result.</returns>
        public static PadenaAssembly DoDenovoAssembly(List<ISequence> sequences)
        {
            // Create a denovo assembler
            ParallelDeNovoAssembler assembler = new ParallelDeNovoAssembler();

            // Length of kmer
            assembler.KmerLength = 6;

            // Threshold to be used for error correction step where dangling links are removed.
            // All dangling links that have lengths less than specified length will be removed.
            assembler.DanglingLinksThreshold = 3;

            // Threshold to be used for error correction step where redundant paths are removed.
            // Paths that have same start and end points (redundant paths) and whose lengths are less 
            // than specified length will be removed. They will be replaced by a single 'best' path
            assembler.RedundantPathLengthThreshold = 7;

            // Enter the name of the library along with mean distance and standard deviation
            CloneLibrary.Instance.AddLibrary("abc", (float)4, (float)5);

            // Assemble
            return (PadenaAssembly)assembler.Assemble(sequences);
        }

        /// <summary>
        /// Do a simple sequence assembly.
        /// This sample uses NeedlemanWunschAligner.
        /// </summary>
        /// <param name="sequences">List of sequences to assemble.</param>
        /// <returns>IDeNovoAssembly which has the assembled result.</returns>
        public static IDeNovoAssembly DoSimpleSequenceAssemble(List<ISequence> sequences)
        {
            // Create an assembler
            OverlapDeNovoAssembler assembler = new OverlapDeNovoAssembler();

            // Setup the parameters
            assembler.OverlapAlgorithm = new NeedlemanWunschAligner();
            assembler.OverlapAlgorithm.SimilarityMatrix = new DiagonalSimilarityMatrix(5, -4);
            assembler.OverlapAlgorithm.GapOpenCost = -10;
            assembler.ConsensusResolver = new SimpleConsensusResolver(66);
            assembler.AssumeStandardOrientation = false;

            return assembler.Assemble(sequences);
        }

        /// <summary>
        /// Aligns multiple sequences using a multiple sequence aligner.
        /// This sample uses PAMSAM with a set of default parameters.
        /// </summary>
        /// <param name="sequences">List of sequences to align.</param>
        /// <returns>List of ISequenceAlignment</returns>
        public static IList<ISequence> DoMultipleSequenceAlignment(List<ISequence> sequences)
        {
            // Initialize objects for constructor
            SimilarityMatrix similarityMatrix = new SimilarityMatrix(SimilarityMatrix.StandardSimilarityMatrix.AmbiguousDna);
            int gapOpenPenalty = -4;
            int gapExtendPenalty = -1;
            int kmerLength = 3;

            DistanceFunctionTypes distanceFunctionName = DistanceFunctionTypes.EuclideanDistance;
            UpdateDistanceMethodsTypes hierarchicalClusteringMethodName = UpdateDistanceMethodsTypes.Average;
            ProfileAlignerNames profileAlignerName = ProfileAlignerNames.NeedlemanWunschProfileAligner;
            ProfileScoreFunctionNames profileProfileFunctionName = ProfileScoreFunctionNames.WeightedInnerProduct;

            // Call aligner
            PAMSAMMultipleSequenceAligner msa = new PAMSAMMultipleSequenceAligner
                (sequences, kmerLength, distanceFunctionName, hierarchicalClusteringMethodName,
                profileAlignerName, profileProfileFunctionName, similarityMatrix, gapOpenPenalty, gapExtendPenalty,
                Environment.ProcessorCount * 2, Environment.ProcessorCount);

            return msa.AlignedSequences;
        }

        /// <summary>
        /// Method to align two sequences, this sample code uses NeedlemanWunschAligner.
        /// </summary>
        /// <param name="referenceSequence">Reference sequence for alignment</param>
        /// <param name="querySequence">Query sequence for alignment</param>
        /// <returns>List of IPairwiseSequenceAlignment</returns>
        public static IList<IPairwiseSequenceAlignment> AlignSequences(ISequence referenceSequence, ISequence querySequence)
        {
            // Initialize the Aligner
            NeedlemanWunschAligner aligner = new NeedlemanWunschAligner();

            // Calling align method to do the alignment.
            return aligner.Align(referenceSequence, querySequence);
        }
    }
}
