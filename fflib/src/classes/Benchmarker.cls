/* Documentation generated with docco for apex */
//This is the Benchmarker class
//====================

//This class purpose is to be a helper to benchmark anything
//---------------------

//This class allow a developer to quickly define something to benchmark
//With the profiler he wants to define
// Benchmarker class is globale without sharing. This is to the developer using
// it to handle the data visibility
// It has been done for the project [AXA Creditor][https://gitlab.com/colladonsebastien/webcreditor.git]

//### Benchmarker class definition
//> The default Threashold is here to handle the maximum threashold available for
//> a user context. It can be overriden to specify a lower context for specific
//> purpose.
global without sharing class Benchmarker {

	private static final decimal DEFAULT_THREASHOLD = 0.95;

	private decimal threashold;

	public map<integer,list<ProfilingResult>> thePRlist {get;private set;}
	public AbstractBenchmarkStrategy theBS;
	public list<AProfiler> thePlist;

	//### Benchmarker constructors
	// Two constructor :
	//1. Constructor per default, use the default threashold
	//2. Constructor allowing a specific threashold. To the user responsability
	// The init method instanciate the result list.
	public Benchmarker() {
		this.threashold = Benchmarker.DEFAULT_THREASHOLD;
		this.init();
	}

	public Benchmarker(decimal threashold) {
		this.threashold = threashold == null ? Benchmarker.DEFAULT_THREASHOLD : threashold;
		this.init();
	}

	private void init(){
		this.thePRlist = new map<integer,list<ProfilingResult>>();
	}

	//### Benchmarker Setter
	// Benchmarker requires :
	//1. A list of profiler
	//2. A Benchmarker Strategy to perform
	public Benchmarker addProfiler(AProfiler aP) {
		if(this.thePlist == null) {
			this.thePlist = new list<AProfiler>();
		}
		this.thePlist.add(aP);
		return this;
	}

	public Benchmarker setBenchmarkStrategy(AbstractBenchmarkStrategy aBS) {
		this.theBS = aBS;
		return this;
	}

	//### Benchmarker Template Method
	// This is the main algorythm for this class
	// Basically it just iterate while the threashold is
	// not reached (against CPU Time consuption)
	// This method will test incrementally to Apply the Benchmarker Stragegy
	// Using the profiler before and after (in the opposite order) to get the metrics
	// Throw BenchmarkerException
	public void DoBenchmark() {
		if(this.theBS == null) {
			throw new BenchmarkException('No Benchmark Strategy set');
		}
		for(integer i = 0 ;
			Limits.getCpuTime()/Limits.getLimitCpuTime() < this.threashold;
			++i) {
			list<ProfilingResult> aPRl = new list<ProfilingResult>();
			for(AProfiler aP : this.thePlist) {
				aP.DoPreAction();
			}
			this.theBS.DoBenchMark(i);
			for(integer k =  this.thePlist.size() - 1 ; k >= 0 ; --k ) {
				system.debug('#=> i k ' + i  + ' ' + k);
				AProfiler aP = this.thePlist[k];
				aP.DoPostAction();
				aPRl.add(aP.getProfilingResult());
			}
			this.thePRlist.put(i,aPRl);
		}
	}

	//This class purpose is to be store the Bencharking results
	//---------------------
	public class ProfilingResult {
		public long metric {get;private set;}
		public ProfilingResult(long metric) {
			this.metric = metric;
		}
	}

	//This interface purpose is to be define the pre Decorator function
	//---------------------
	public interface IPreDecorator {
		void DoPreAction();
	}

	//This interface purpose is to be define the post Decorator function
	//---------------------
	public interface IPostDecorator {
		void DoPostAction();
	}

	//This Class define the super type for profiler
	//---------------------
	//### AProfiler class
	// The constructor is private so it is not possible to instanciate it
	// It implement IPreDecorator and IPostDecorator
	// The only method to override is the GetMetrics, the class will automatically
	// fetch the metrics by substracting the postdecorator result with the predecorator result
	// Throw ProfilerStartMetricException ProfilerEndMetricException
	public abstract class AProfiler implements IPreDecorator, IPostDecorator {
		private long metricStart;
		private long metricEnd;

		private AProfiler(){}

		private abstract long GetMetric();
		public void DoPreAction() {
			this.metricStart = this.GetMetric();
		}
		public void DoPostAction() {
			this.metricEnd = this.GetMetric();
		}
		public ProfilingResult getProfilingResult() {
			if(this.metricStart == null) {
				throw new ProfilerStartMetricException('No Start Metric');
			}
			if(this.metricEnd == null) {
				throw new ProfilerEndMetricException('No End Metric');
			}
			system.debug('#=> AProfiler.getProfilingResult ' + this.metricEnd + ' ' + this.metricStart);
			return new ProfilingResult(this.metricEnd - this.metricStart);
		}
	}

	//### Concrete Instantiation for AProfiler, monitoring the time
	private class TimeProfiler extends AProfiler {
		private override long GetMetric(){
			long m = DateTime.now().gettime();
			system.debug('#=> TimeProfiler.GetMetric ' + m);

			return m;
		}
	}

	//### Concrete Instantiation for AProfiler, monitoring the heap
	private class HeapSizeProfiler extends AProfiler {
		private override long GetMetric(){
			long m = Limits.getHeapSize();
			system.debug('#=> HeapSizeProfiler.GetMetric ' + m);
			return m;
		}
	}

	//### Profiler Factory hiding the Profiler Creation
	public class ProfilerFactory {
		public AProfiler getTimeProfiler(){
			return new TimeProfiler();
		}

		public AProfiler getHeapSizeProfiler(){
			return new HeapSizeProfiler();
		}
	}

	//This Class define the super type for BenchmarkStrategy
	//---------------------
	//### AbstractBenchmarkStrategy class
	// This class only define one method to be overriden
	// The DoBecnhmark method, which purpose is to do an atomic task to Benchmark
	public abstract class AbstractBenchmarkStrategy {
		public abstract void DoBenchMark(integer iteration);
	}

	//### Concrete Instantiation for AbstractBenchmarkStrategy, Concat string
	private class StringConcatBenchmarkStrategy extends AbstractBenchmarkStrategy {
		public override void DoBenchmark(integer iteration){
			string s = '';
			for(integer i = 0 ; i < iteration ; ++i) {
				s += 's';
			}
		}
	}

	//### Concrete Instantiation for AbstractBenchmarkStrategy, Join string
	private class StringJoinBenchmarkStrategy extends AbstractBenchmarkStrategy {
		public override void DoBenchmark(integer iteration){
			list<string> ls = new list<string>();
			for(integer i = 0 ; i < iteration ; ++i) {
				ls.add('s');
			}
			string.join(ls,'');
		}
	}

	//### BenchmarkStrategy Factory hiding the BanchmarkerStrategy Creation
	public class BenchmarkStrategyFactory {
		public AbstractBenchmarkStrategy getStringConcatBenchmarkStrategy(){
			return new StringConcatBenchmarkStrategy();
		}

		public AbstractBenchmarkStrategy getStringJoinBenchmarkStrategy(){
			return new StringJoinBenchmarkStrategy();
		}
	}

	//Specific Exception type for the Benchmarker
	//---------------------
	//1. BenchmarkerException => Thrown when a Benchmarker is executed without Benchmarker Strategy
	//2. ProfilerStartMetricException => Thrown when no start Metric retrieved
	//3. ProfilerEndMetricException => Thrown when no end Metric retrieved
	public class BenchmarkException extends Exception {}
	public class ProfilerStartMetricException extends Exception {}
	public class ProfilerEndMetricException extends Exception {}
}