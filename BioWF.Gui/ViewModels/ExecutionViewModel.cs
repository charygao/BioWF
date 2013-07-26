using System;
using System.Activities;
using System.Activities.XamlIntegration;
using System.Collections.ObjectModel;
using System.IO;
using System.Windows.Input;
using System.Xaml;
using BioWF.Extensions;
using JulMar.Windows.Interfaces;
using JulMar.Windows.Mvvm;
using System.Collections.Generic;

namespace BioWF.ViewModels
{
    /// <summary>
    /// This view model is used to execute a workflow.
    /// </summary>
    public sealed class ExecutionViewModel : ViewModel
    {
        private readonly string _filename;
        private bool _isRunning;
        private Activity _workflow;
        private WorkflowInvoker _invoker;
        private Dictionary<string, object> _inputs;

        /// <summary>
        /// Title for this workflow execution
        /// </summary>
        public string Title
        {
            get
            {
                return Path.GetFileNameWithoutExtension(_filename);
            }
        }

        /// <summary>
        /// Log used to output results
        /// </summary>
        public IList<string> Log { get; private set; }

        /// <summary>
        /// True if the workflow is currently executing
        /// </summary>
        public bool IsRunning
        {
            get { return _isRunning; }
            private set { SetPropertyValue(ref _isRunning, value); }
        }

        /// <summary>
        /// Cancellation support
        /// </summary>
        public ICommand Cancel { get; private set; }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="filename">Filename of the workflow to run</param>
        public ExecutionViewModel(string filename)
        {
            _filename = filename;
            Log = new ObservableCollection<string>();
            Cancel = new DelegateCommand(OnCancel, () => IsRunning);
        }

        /// <summary>
        /// 2-phase initialization to parse parameters
        /// </summary>
        /// <returns></returns>
        public bool Initialize()
        {
            XamlXmlReader reader = new XamlXmlReader(_filename, new XamlXmlReaderSettings { LocalAssembly = typeof(MainViewModel).Assembly });
            _workflow = ActivityXamlServices.Load(reader);
            
            var argumentViewModel = new ArgumentCollectorViewModel(_workflow as DynamicActivity);
            if (argumentViewModel.HasArguments)
            {
                IUIVisualizer uiVisualizer = Resolve<IUIVisualizer>();
                if (uiVisualizer.ShowDialog("WorkflowArgumentsView", argumentViewModel) == false)
                    return false;
            }
            
            _inputs = argumentViewModel.CollectArguments();

            return true;
        }

        /// <summary>
        /// Cancels the operation.
        /// </summary>
        private void OnCancel()
        {
            if (IsRunning)
                _invoker.CancelAsync(this);
        }

        /// <summary>
        /// Starts the workflow execution
        /// </summary>
        public void Start()
        {
            if (_workflow == null)
                return;

            _invoker = new WorkflowInvoker(_workflow);
            _invoker.InvokeCompleted += InvokerOnInvokeCompleted;
            _invoker.Extensions.Add(new OutputWriter(this.Log));

            if (_inputs != null && _inputs.Count > 0)
            {
                Log.Add("Input values:");
                foreach (var item in _inputs)
                {
                    Log.Add(string.Format("  {0} = {1}", item.Key, item.Value));
                }
            }

            try
            {
                IsRunning = true;
                _invoker.InvokeAsync(_inputs, this);
            }
            catch (Exception ex)
            {
                Log.Add(string.Format("Failed to start workflow: {0}", ex.Message));
                Log.Add(ex.StackTrace);
            }
            finally
            {
                IsRunning = false;
            }
        }

        /// <summary>
        /// Called when the workflow is completed.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void InvokerOnInvokeCompleted(object sender, InvokeCompletedEventArgs e)
        {
            IsRunning = false;
            if (e.Cancelled)
            {
                Log.Add("Run was cancelled.");
                return;
            }

            if (e.Error != null)
            {
                Log.Add(string.Format("Run failed: {0}", e.Error.Message));
                Log.Add(e.Error.StackTrace);
                return;
            }

            Log.Add("Run completed successfully.");

            var outputs = e.Outputs;
            if (outputs != null)
            {
                Log.Add("Output values:");
                foreach (var item in outputs)
                {
                    Log.Add(string.Format("  {0} = {1}", item.Key, item.Value));
                }
            }
        }
    }
}
