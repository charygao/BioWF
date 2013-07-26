using System.ComponentModel;
using Bio;
using Bio.Algorithms.Alignment;
using System;
using System.Activities;
using System.Linq;
using Bio.SimilarityMatrices;

namespace BioWF.Activities
{
    /// <summary>
    /// Simple activity to perform a pairwise alignment
    /// </summary>
    public sealed class AlignSequencePair : CodeActivity<ISequenceAlignment>
    {
        public const string DefaultAligner = "Smith-Waterman";
        public const string DefaultMatrix = "DiagonalScoreMatrix";
        public const int DefaultGapOpenCost = -8;

        [RequiredArgument]
        [Category(ActivityConstants.InputGroup)]
        [Description("First sequence to align.")]
        public InArgument<ISequence> FirstSequence { get; set; }

        [RequiredArgument]
        [Category(ActivityConstants.InputGroup)]
        [Description("Second sequence to align.")]
        public InArgument<ISequence> SecondSequence { get; set; }

        [RequiredArgument]
        [DefaultValue(DefaultAligner)]
        [Category(ActivityConstants.InputGroup)]
        [Description("Name of the aligner to use.")]
        public string AlignerName { get; set; }

        [DefaultValue(DefaultMatrix)]
        [Category(ActivityConstants.InputGroup)]
        [Description("Similarity Matrix to use for comparison.")]
        public string SimilarityMatrix { get; set; }

        [RequiredArgument]
        [DefaultValue(DefaultGapOpenCost)]
        [Category(ActivityConstants.InputGroup)]
        [Description("Gap open cost.")]
        public int GapOpenCost { get; set; }

        [Category(ActivityConstants.InputGroup)]
        [Description("Gap extension cost.")]
        public int GapExtensionCost { get; set; }

        [Category(ActivityConstants.OutputGroup)]
        public OutArgument<ISequence> Consensus { get; set; }
        [Category(ActivityConstants.OutputGroup)]
        public OutArgument<ISequence> FirstResult { get; set; }
        [Category(ActivityConstants.OutputGroup)]
        public OutArgument<ISequence> SecondResult { get; set; }

        public AlignSequencePair()
        {
            GapOpenCost = DefaultGapOpenCost;
            SimilarityMatrix = DefaultMatrix;
            AlignerName = DefaultAligner;
        }

        /// <summary>
        /// When implemented in a derived class, performs the execution of the activity.
        /// </summary>
        /// <returns>
        /// The result of the activity’s execution.
        /// </returns>
        /// <param name="context">The execution context under which the activity executes.</param>
        protected override ISequenceAlignment Execute(CodeActivityContext context)
        {
            string alignerName = (AlignerName ?? DefaultAligner).ToLowerInvariant();
            var aligner = SequenceAligners.All.FirstOrDefault(sa => sa.Name.ToLowerInvariant() == alignerName);
            if (aligner == null)
                throw new ArgumentException("Could not find aligner: " + alignerName);

            aligner.GapOpenCost = GapOpenCost;
            aligner.GapExtensionCost = GapExtensionCost;

            var smName = SimilarityMatrix ?? DefaultMatrix;
            SimilarityMatrix.StandardSimilarityMatrix sm;
            if (Enum.TryParse(smName, true, out sm))
            {
                aligner.SimilarityMatrix = new SimilarityMatrix(sm);
            }

            ISequenceAlignment result;
            if (GapOpenCost == GapExtensionCost || GapExtensionCost == 0)
            {
                result = aligner.AlignSimple(new[] {FirstSequence.Get(context), SecondSequence.Get(context)}).First();
            }
            else
            {
                result = aligner.Align(new[] { FirstSequence.Get(context), SecondSequence.Get(context) }).First();
            }

            IPairwiseSequenceAlignment pwAlignment = result as IPairwiseSequenceAlignment;
            if (pwAlignment != null)
            {
                if (pwAlignment.PairwiseAlignedSequences.Count > 0)
                {
                    FirstResult.Set(context, pwAlignment.PairwiseAlignedSequences[0].FirstSequence);
                    SecondResult.Set(context, pwAlignment.PairwiseAlignedSequences[0].SecondSequence);
                    Consensus.Set(context, pwAlignment.PairwiseAlignedSequences[0].Consensus);
                }
            }

            return result;
        }
    }
}
