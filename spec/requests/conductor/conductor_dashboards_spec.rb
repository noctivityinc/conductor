require 'spec_helper'

describe "Dashboards" do
  describe "GET /conductor_dashboards" do
    it "gets the conductor dashboard" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get(conductor_dashboard_path, :use_route => :conductor)
      response.status.should be(200)
    end

    describe "GET /conductor/" do
      before do
        seed_raw_data(100)
        Conductor::RollUp.process

        visit conductor_dashboard_path
      end

      it "has a heading of conductor statistics" do
        page.should have_content("Conductor Statistics")
      end

      it "has a group stats div with data" do
        page.should have_css('div#group_stats table')
      end

      it "has a chart of daily experiments" do
        page.should have_css('div#dailies div.chart > img')
      end

    end
  end
end

