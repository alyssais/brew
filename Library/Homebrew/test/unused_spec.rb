describe "brew unused", :integration_test do
  it "prints unused Formulae" do
    setup_test_formula "testball"
    setup_test_formula "testball_dependent", <<-EOS
      depends_on "testball"

      def install
        (bin/name).write("echo test\n")
      end
    EOS

    shutup { brew "install", "testball_dependent" }
    shutup { brew "uninstall", "testball_dependent" }

    expect { brew "unused" }
      .to output("testball 0.1\n").to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end
end
