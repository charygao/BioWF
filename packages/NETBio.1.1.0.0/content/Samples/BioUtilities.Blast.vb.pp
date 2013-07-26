#If False
' Comment out the above if you want to use the below code.
' You must have the full framework targeted and have Bio.WebServiceHandlers.dll
' as a reference (automatically added by NuGet if you are a full framework application)
Imports Bio
Imports Bio.Web.Blast
Imports System.IO
Imports Bio.Web

Namespace Samples
    Partial Public Class BioUtilities
        ''' <summary>
        ''' Submits a blast query to a blast search provider.
        ''' This sample uses NCBI as the provider.
        ''' </summary>
        ''' <param name="sequence">Sequence to submit for searching.</param>
        ''' <returns>Job ID of the query. You can get the results using GetBlastResults after the job is completed.</returns>
        Public Shared Function SubmitBlastQuery(ByVal sequence As ISequence) As String
            ' Create the service provider
            Dim serviceProvider As New NCBIBlastHandler

            ' Configure it
            Dim configParams As New ConfigParameters
            configParams.UseBrowserProxy = True
            serviceProvider.Configuration = configParams

            ' Return the BLAST request
            Return serviceProvider.SubmitRequest(sequence, GetBlastSearchParams)
        End Function

        ''' <summary>
        ''' Gets the blast results from a given job ID.
        ''' If the job is not complete, this method will throw an exception.
        ''' </summary>
        ''' <param name="jobID">Job ID for which the blast results should be fetched.</param>
        ''' <returns>List of BlastResult.</returns>
        Public Shared Function GetBlastResults(ByVal jobID As String) As IList(Of BlastResult)
            ' Create the service provider
            Dim serviceProvider As New NCBIBlastHandler
            Dim configParams As New ConfigParameters

            configParams.UseBrowserProxy = True
            serviceProvider.Configuration = configParams

            ' Check the job status
            If (serviceProvider.GetRequestStatus(jobID).Status <> ServiceRequestStatus.Ready) Then
                Throw New InvalidOperationException("Blast search results are not yet ready!")
            End If

            ' Return the results
            Dim blastXmlParser As IBlastParser = New BlastXmlParser
            Return blastXmlParser.Parse(New StringReader(serviceProvider.GetResult(jobID, GetBlastSearchParams)))
        End Function

        ''' <summary>
        ''' Create sample blast parameters.
        ''' </summary>
        ''' <returns>BlastParameters object.</returns>
        Private Shared Function GetBlastSearchParams() As BlastParameters
            Dim searchParams As New BlastParameters
            searchParams.Add("Program", "blastn")
            searchParams.Add("Database", "nr")
            searchParams.Add("Expect", "1e-10")
            searchParams.Add("CompositionBasedStatistics", "0")
            Return searchParams
        End Function

    End Class
End Namespace
#End If