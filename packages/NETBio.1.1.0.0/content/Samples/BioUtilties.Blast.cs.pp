#if false
// Comment out the above if you want to use the below code.
// You must have the full framework targeted and have Bio.WebServiceHandlers.dll
// as a reference (automatically added by NuGet if you are a full framework application)
using System;
using System.Collections.Generic;
using Bio;
using Bio.Web.Blast;
using Bio.Web;

namespace $rootnamespace$.Samples
{
    public static partial class BioUtilities
    {
        /// <summary>
        /// Submits a blast query to a blast search provider.
        /// This sample uses NCBI as the provider.
        /// </summary>
        /// <param name="sequence">Sequence to submit for searching.</param>
        /// <returns>Job ID of the query. You can get the results using GetBlastResults after the job is completed.</returns>
        public static string SubmitBlastQuery(ISequence sequence)
        {
            // Create the service provider
            NCBIBlastHandler serviceProvider = new NCBIBlastHandler();

            ConfigParameters configParams = new ConfigParameters();
            configParams.UseBrowserProxy = true;
            serviceProvider.Configuration = configParams;

            // create the request and return the job ID.
            return serviceProvider.SubmitRequest(sequence, GetBlastSearchParams());
        }

        /// <summary>
        /// Gets the blast results from a given job ID.
        /// If the job is not complete, this method will throw an exception.
        /// </summary>
        /// <param name="jobID">Job ID for which the blast results should be fetched.</param>
        /// <returns>List of BlastResult.</returns>
        public static IList<BlastResult> GetBlastResults(string jobID)
        {
            // Create the service provider
            NCBIBlastHandler serviceProvider = new NCBIBlastHandler();

            ConfigParameters configParams = new ConfigParameters();
            configParams.UseBrowserProxy = true;
            serviceProvider.Configuration = configParams;

            // Check the job status
            ServiceRequestInformation info = serviceProvider.GetRequestStatus(jobID);
            if (info.Status != ServiceRequestStatus.Ready)
            {
                throw new InvalidOperationException("Blast search results are not yet ready!");
            }

            // Get the results back and parse it.
            IBlastParser blastXmlParser = new BlastXmlParser();
            return blastXmlParser.Parse(new System.IO.StringReader(serviceProvider.GetResult(jobID, GetBlastSearchParams())));
        }

        /// <summary>
        /// Create sample blast parameters.
        /// </summary>
        /// <returns>BlastParameters object.</returns>
        static BlastParameters GetBlastSearchParams()
        {
            BlastParameters searchParams = new BlastParameters();
            searchParams.Add("Program", "blastn");
            searchParams.Add("Database", "nr");
            // higher Expect will return more results
            searchParams.Add("Expect", "1e-10");
            searchParams.Add("CompositionBasedStatistics", "0");

            return searchParams;
        }
    }
}
#endif