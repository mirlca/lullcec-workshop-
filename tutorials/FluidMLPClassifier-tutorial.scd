


FluidMLPClassifier // Command + D to open the Help File

// We will explore the first Example from the Help File


(
~classifier = FluidMLPClassifier(s, [6], FluidMLPClassifier.tanh, 1000, 0.1, 0.1, 50, 0);
~sourcedata= FluidDataSet(s,\mlpclassify_help_examples);
~labels = FluidLabelSet(s,\mlpclassify_help_labels);
~testdata = FluidDataSet(s,\mlpclassify_help_test);
~predictedlabels = FluidLabelSet(s,\mlpclassify_help_mapping);
)

//Make some clumped 2D points and place into a DataSet
(
~centroids = [[0.5,0.5],[-0.5,0.5],[0.5,-0.5],[-0.5,-0.5]];
~categories = [\red,\orange,\green,\blue];
~trainingset = Dictionary();
~labeldata = Dictionary();
4.do{ |i|
    64.do{ |j|
        ~trainingset.put("mlpclass"++i++\_++j, ~centroids[i].collect{|x| x.gauss(0.5/3)});
        ~labeldata.put("mlpclass"++i++\_++j,[~categories[i]]);
    }
};
~sourcedata.load(Dictionary.with(*[\cols->2,\data->~trainingset]));
~labels.load(Dictionary.with(*[\cols->1,\data->~labeldata]));
)

//Fit the classifier to the example DataSet and labels, and then run prediction on the test data into our mapping label set
~classifier.fit(~sourcedata,~labels,action:{|loss| ("Trained"+loss).postln});

//make some test data
(
~testset = Dictionary();
4.do{ |i|
    64.do{ |j|
        ~testset.put("mlpclass_test"++i++\_++j, ~centroids[i].collect{|x| x.gauss(0.5/3)});
    }
};
~testdata.load(Dictionary.with(*[\cols->2,\data->~testset]));
)

//Run the test data through the network, into the predicted labelset
~classifier.predict(~testdata,~predictedlabels,action:{"Test complete".postln});

//get labels from server
~predictedlabels.dump(action:{|d| ~labelsdict = d["data"]});

//Visualise: we're hoping to see colours neatly mapped to quandrants...
(
c = Dictionary();
c.add("red"->Color.red);
c.add("blue"->Color.blue);
c.add("green"->Color.green);
c.add("orange"->Color.new255(255, 127, 0));
e = 200 * ((~centroids + 1) * 0.5).flatten(1).unlace;
w = Window("scatter", Rect(128, 64, 200, 200));
w.drawFunc = {
    Pen.use {
        ~testset.keysValuesDo{|k,v|
            var x = v[0].linlin(-1,1,200,0).asInteger;
            var y = v[1].linlin(-1,1,200,0).asInteger;
            var r = Rect(x,y,5,5);
            Pen.fillColor = c.at(~labelsdict[k][0]);
            Pen.fillOval(r);
        }
    }
};
w.refresh;
w.front;
)

// single point transform on arbitrary value
~inbuf = Buffer.loadCollection(s,0.5.dup);
~classifier.predictPoint(~inbuf,{|x|x.postln;});