using System.Windows;
using BioWF.ViewModels;
using JulMar.Windows.UI;

namespace BioWF.Views
{
    /// <summary>
    /// Interaction logic for WorkflowExecutionWindow.xaml
    /// </summary>
    [ExportUIVisualizer("ExecutionWindow")]
    public partial class WorkflowExecutionWindow
    {
        public WorkflowExecutionWindow()
        {
            Loaded += OnLoaded;
            InitializeComponent();
        }

        private void OnLoaded(object sender, RoutedEventArgs routedEventArgs)
        {
            ((ExecutionViewModel) DataContext).Start();
        }
    }
}
