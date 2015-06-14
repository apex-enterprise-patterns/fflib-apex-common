public with sharing class StringBenchmarkCtrl {

    public list<ResourceConsumptionTracker> aRctl {get;private set;}

    public StringBenchmarkCtrl() { 
        this.aRctl = new list<ResourceConsumptionTracker>();
    }

    public void getJoinBenchmark() {
        this.aRctl.clear();
        BenchMarker aBM = new BenchMarker();
        BenchMarker.ProfilerFactory aPF = new BenchMarker.ProfilerFactory();
        BenchMarker.BenchmarkStrategyFactory aBSF = new BenchMarker.BenchmarkStrategyFactory();
        aBM
            .setBenchmarkStrategy(aBSF.getStringJoinBenchmarkStrategy())
            .addProfiler(aPF.getTimeProfiler())
        ;
        aBM.DoBenchmark();
        for(integer index : aBM.thePRlist.keyset()) {
            list<Benchmarker.ProfilingResult> prl = aBM.thePRlist.get(index);         
            long timeMetric = prl[0].metric;
            this.aRctl.add(new ResourceConsumptionTracker(index,timeMetric));
        }
    }

    public void getConcatBenchmark() {
        this.aRctl.clear();
        BenchMarker aBM = new BenchMarker();
        BenchMarker.ProfilerFactory aPF = new BenchMarker.ProfilerFactory();
        BenchMarker.BenchmarkStrategyFactory aBSF = new BenchMarker.BenchmarkStrategyFactory();
        aBM
            .setBenchmarkStrategy(aBSF.getStringConcatBenchmarkStrategy())
            .addProfiler(aPF.getTimeProfiler())
        ;
        aBM.DoBenchmark();
        for(integer index : aBM.thePRlist.keyset()) {
            list<Benchmarker.ProfilingResult> prl = aBM.thePRlist.get(index);            
            long timeMetric = prl[0].metric;
            this.aRctl.add(new ResourceConsumptionTracker(index,timeMetric));
        }
    }
    
    public void getConcatBenchmarkQuick() {
        this.aRctl.clear();
        //decimal max = (decimal)Limits.getLimitCpuTime();
        integer max = Limits.getLimitCpuTime();
        for(integer i = 0 ; 
            //((decimal)Limits.getCpuTime())/max < 0.95; // ! int/int gives an int, will always reach or step over limitCPUTime // if one operation takes more than (limitCPU * (1 - threashold)) time: overtime
            (Limits.getCpuTime())/max < 0.95;
            ++i) {
            long t = DateTime.now().gettime();
            string s = '';
            for(integer k = 0 ; k < i ; ++k) {
                s += 's';
            }            
            this.aRctl.add(new ResourceConsumptionTracker(i, DateTime.now().gettime()-t));
        }
        
    }

    // Chart Wrapper
    public class ResourceConsumptionTracker {
        public integer index        {get;private set;}
        public long timeMetric      {get;private set;}

        public ResourceConsumptionTracker(integer index, long timeMetric) {
            this.index  = index;
            this.timeMetric   = timeMetric;
        }
    }
}