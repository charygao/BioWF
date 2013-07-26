Imports Bio.Algorithms.Assembly
Imports Bio.Algorithms.Alignment
Imports Bio
Imports Bio.IO.FastA
Imports Bio.Algorithms.Assembly.Padena
Imports Bio.SimilarityMatrices
Imports Bio.Algorithms.Alignment.MultipleSequenceAlignment

Namespace Samples
    Partial Public Class BioUtilities

        ''' <summary>
        ''' Method to align two sequences, this sample code uses NeedlemanWunschAligner.
        ''' </summary>
        ''' <param name="referenceSequence">Reference sequence for alignment</param>
        ''' <param name="querySequence">Query sequence for alignment</param>
        ''' <returns>List of IPairwiseSequenceAlignment</returns>
        Public Shared Function AlignSequences(ByVal referenceSequence As ISequence, ByVal querySequence As ISequence) As IList(Of IPairwiseSequenceAlignment)
            Dim aligner As New NeedlemanWunschAligner
            Return aligner.Align(referenceSequence, querySequence)
        End Function

        ''' <summary>
        ''' Merges two sequence ranges with default parameters.
        ''' </summary>
        ''' <param name="referenceSequence">Reference sequence for merging.</param>
        ''' <param name="querySequence">Query sequence for merging.</param>
        ''' <returns>SequenceRangeGrouping with merged output.</returns>
        Public Shared Function DoBEDMerge(ByVal referenceSequence As SequenceRangeGrouping, ByVal querySequence As SequenceRangeGrouping) As SequenceRangeGrouping
            Return referenceSequence.MergeOverlaps(querySequence, 0, False)
        End Function

        ''' <summary>
        ''' Method to do a denovo assembly.
        ''' This sample uses Padena Denovo assembler.
        ''' </summary>
        ''' <param name="sequences">List of sequences to assemble.</param>
        ''' <returns>PadenaAssembly which contain the assembled result.</returns>
        Public Shared Function DoDenovoAssembly(ByVal sequences As List(Of ISequence)) As PadenaAssembly
            Dim assembler As New ParallelDeNovoAssembler

            ' Length of kmer
            assembler.KmerLength = 6

            ' Threshold to be used for error correction step where dangling links are removed.
            ' All dangling links that have lengths less than specified length will be removed.
            assembler.DanglingLinksThreshold = 3

            ' Threshold to be used for error correction step where redundant paths are removed.
            ' Paths that have same start and end points (redundant paths) and whose lengths are less 
            ' than specified length will be removed. They will be replaced by a single 'best' path
            assembler.RedundantPathLengthThreshold = 7

            ' Enter the name of the library along with mean distance and standard deviation
            CloneLibrary.Instance.AddLibrary("abc", 4.0!, 5.0!)

            ' Assemble
            Return DirectCast(assembler.Assemble(sequences), PadenaAssembly)
        End Function

        ''' <summary>
        ''' Aligns multiple sequences using a multiple sequence aligner.
        ''' This sample uses PAMSAM with a set of default parameters.
        ''' </summary>
        ''' <param name="sequences">List of sequences to align.</param>
        ''' <returns>List of ISequenceAlignment</returns>
        Public Shared Function DoMultipleSequenceAlignment(ByVal sequences As List(Of ISequence)) As IList(Of ISequence)

            ' Initialize objects for constructor
            Dim similarityMatrix As New SimilarityMatrix(similarityMatrix.StandardSimilarityMatrix.AmbiguousDna)
            Dim gapOpenPenalty As Integer = -4
            Dim gapExtendPenalty As Integer = -1
            Dim kmerLength As Integer = 3
            Dim distanceFunctionName As DistanceFunctionTypes = DistanceFunctionTypes.EuclideanDistance
            Dim hierarchicalClusteringMethodName As UpdateDistanceMethodsTypes = UpdateDistanceMethodsTypes.Average
            Dim profileAlignerName As ProfileAlignerNames = ProfileAlignerNames.NeedlemanWunschProfileAligner
            Dim profileProfileFunctionName As ProfileScoreFunctionNames = ProfileScoreFunctionNames.WeightedInnerProduct

            ' Call aligner
            Dim msa As New PAMSAMMultipleSequenceAligner(sequences, kmerLength, distanceFunctionName,
                                                         hierarchicalClusteringMethodName, profileAlignerName,
                                                         profileProfileFunctionName, similarityMatrix, gapOpenPenalty, gapExtendPenalty,
                                                         (Environment.ProcessorCount * 2), Environment.ProcessorCount)
            Return msa.AlignedSequences
        End Function

        ''' <summary>
        ''' Do a simple sequence assembly.
        ''' This sample uses NeedlemanWunschAligner.
        ''' </summary>
        ''' <param name="sequences">List of sequences to assemble.</param>
        ''' <returns>IDeNovoAssembly which has the assembled result.</returns>
        Public Shared Function DoSimpleSequenceAssemble(ByVal sequences As List(Of ISequence)) As IDeNovoAssembly
            ' Create an assembler and setup the parameters
            Dim assembler As New OverlapDeNovoAssembler
            assembler.OverlapAlgorithm = New NeedlemanWunschAligner
            assembler.OverlapAlgorithm.SimilarityMatrix = New DiagonalSimilarityMatrix(5, -4)
            assembler.OverlapAlgorithm.GapOpenCost = -10
            assembler.ConsensusResolver = New SimpleConsensusResolver(66)
            assembler.AssumeStandardOrientation = False

            ' Assemble
            Return assembler.Assemble(sequences)
        End Function

        ''' <summary>
        ''' Exports a given sequence to a file in FastA format
        ''' </summary>
        ''' <param name="sequence">Sequence to be exported</param>
        ''' <param name="filename">Target filename.</param>
        Public Shared Sub ExportFastA(ByVal sequence As ISequence, ByVal filename As String)
            Dim formatter As New FastAFormatter(filename)
            formatter.Write(sequence)
        End Sub

        ''' <summary>
        ''' Exports a given list of sequences to a file in FastA format
        ''' </summary>
        ''' <param name="sequences">List of Sequences to be exported.</param>
        ''' <param name="filename">Target filename.</param>
        Public Shared Sub ExportFastA(ByVal sequences As ICollection(Of ISequence), ByVal filename As String)
            Dim formatter As New FastAFormatter(filename)
            formatter.Write(sequences)
        End Sub

        ''' <summary>
        ''' Parses a FastA file which has one or more sequences.
        ''' </summary>
        ''' <param name="filename">Path to the file to be parsed.</param>
        ''' <returns>ISequence objects</returns>
        Public Shared Function ParseFastA(ByVal filename As String) As IEnumerable(Of ISequence)
            Dim parser As New FastAParser(filename)
            Return parser.Parse
        End Function

    End Class
End Namespace