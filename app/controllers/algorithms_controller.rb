class AlgorithmsController < ApplicationController
  # GET /algorithms
  # GET /algorithms.json
  require 'java'
  require 'json'
  import 'weka.classifiers'
  import 'weka.classifiers.functions'
  include_class "weka.classifiers.Classifier"
  include_class "java.io.FileReader"
  include_class "weka.core.Instances"
  include_class "weka.core.Instance"
  include_class "weka.core.Attribute"
  include_class "weka.core.xml.XMLSerialization"
  include_class "java.io.BufferedReader"
  include_class "weka.classifiers.xml.XMLClassifier"
  
  def index
    @algorithms = Algorithm.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @algorithms }
    end
  end

  # GET /algorithms/1
  # GET /algorithms/1.json
  def show
    @algorithm = Algorithm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @algorithm }
    end
  end

  # GET /algorithms/new
  # GET /algorithms/new.json
  def new
    @algorithm = Algorithm.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @algorithm }
    end
  end

  # GET /algorithms/1/edit
  def edit
    @algorithm = Algorithm.find(params[:id])
  end

  # POST /algorithms
  # POST /algorithms.json
  def create
    file_name = Rails.root.join('public/autoPrice.arff').to_s
    file = FileReader.new(file_name)
    train_data = Instances.new file
    train_data.set_class_index(train_data.num_attributes() - 1)
    case params[:algorithm][:algorithm]
    when 'LinearRegression'
      classifier = LinearRegression.new
    when 'SimpleLinearRegression'
      classifier = SimpleLinearRegression.new
    when 'SMO'
      classifier = SMO.new
    when 'SMOreg'
      classifier = SMOreg.new
    when 'VotedPerceptron'
      classifier = VotedPerceptron.new
    else
      classifier = LinearRegression.new
    end
    classifier.build_classifier train_data
    debugger
    params[:algorithm][:data] = Marshal.dump(classifier)
    params[:algorithm][:file] = file_name
    @algorithm = Algorithm.new(params[:algorithm])
    respond_to do |format|
      if @algorithm.save
        format.html { redirect_to @algorithm, notice: 'Algorithm was successfully created.' }
        format.json { render json: @algorithm, status: :created, location: @algorithm }
      else
        format.html { render action: "new" }
        format.json { render json: @algorithm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /algorithms/1
  # PUT /algorithms/1.json
  def update
    @algorithm = Algorithm.find(params[:id])

    respond_to do |format|
      if @algorithm.update_attributes(params[:algorithm])
        format.html { redirect_to @algorithm, notice: 'Algorithm was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @algorithm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /algorithms/1
  # DELETE /algorithms/1.json
  def destroy
    @algorithm = Algorithm.find(params[:id])
    @algorithm.destroy

    respond_to do |format|
      format.html { redirect_to algorithms_url }
      format.json { head :no_content }
    end
  end
  
  def classify
    algorithm = Algorithm.find(params[:id])
    classifier = Marshal.load(algorithm.data)
    file = FileReader.new(algorithm.file)
    train_data = Instances.new file
    train_data.set_class_index(train_data.num_attributes() - 1)
    arr = JSON.parse params[:instance]
    inst = train_data.first_instance.copy
    inst.enumerate_attributes.each_with_index do |attr,i|
      inst.set_value i,arr[i]
    end
    @result = classifier.classify_instance(inst)
    respond_to do |format|
      format.json {render :json => @result}
    end
  end
end