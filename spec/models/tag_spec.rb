require File.join(File.dirname(__FILE__), "/../spec_helper")

class Tag
  has_many_polymorphs :freetaggables, :from => [:contacts], :through => :taggings
  # # has_many polymorphs DOES work with seperate listings
  has_many_polymorphs :freetaggables, :from => [:comments], :through => :taggings
end

describe Tag do
  fixtures :tags

  specify { Tag.should have_many :taggings}

  # These 2 show has_many_polymorphs works with seperate declarations
  specify { Tag.should have_many :contacts }
  specify { Tag.should have_many :comments }

  # should "act as list" do
  #   assert_respond_to @tag, :move_higher
  # end
  
  context "ordering" do
    it "can reorder tags"
    it "{ should respond_to :move_up }"
    it "{ should respond_to :move_down }"
  end
  
  context "tree" do
    subject { Tag }
    specify { Tag.should respond_to :roots }
    
    it "should tidy up orphaned objects" do
      # Note #delete does _NOT_ trigger children deletion
      parent = Tag.create!
      child_id = parent.children.create!.id
      grand_child_id = parent.children[0].children.create!.id
      parent.destroy
      lambda { Tag.find child_id }.should raise_error
      lambda { Tag.find grand_child_id }.should raise_error
    end
    it "should be capable of mass child reassignment" do
      pending "when I find out why << works in script/console but not specs"
      root2_count = @root2.children.count
      root1_count = @root.children.count
      puts @root, @root2.children
      (@root.children << @root2.children).should be true
      puts @root
      @root.should be_valid
      @root.save; @root.reload
      @root.children.count.should be root1_count + root2_count
      #   t2.reload
      #   assert (t2.children.length == tccount + t2ccount)
    end
    it "node 'root' has 2 children" do
      @root.children.count.should be 2
    end
    it "node 'root' has 3 descendants" do
      @root.descendants.count.should be 3
    end
    it "node 'tag_one's parent is  node 'root'" do
      @tag_one.parent.should == @root
    end
    it "node 'tag_one' has 1 sibling" do
      @tag_one.siblings.count.should be 1
    end
    it "node 'tag_two_one' has 2 ancestors" do
      @tag_two_one.ancestors.count.should be 2
    end
  end
  
  context "tree node" do
    before(:each) do
      @tag = Tag.create
    end
    subject { @tag }
    it { should respond_to :children }
    it { should respond_to :descendants }
    it { should respond_to :parent }
    it { should respond_to :parent= }
    it { should respond_to :ancestors }
    it "cannot be its own parent" do
      @tag.parent = @tag
      @tag.should_not be_valid
    end
    it "can change parent" do
      @tag2 = Tag.create
      lambda { @tag.parent = @tag2 }.should_not raise_error
      @tag.parent.should == @tag2
    end
    it "can leave its parent and become root" do
      @tag2 = Tag.create
      @tag.parent = @tag2
      @tag.parent = nil
      @tag.save
      @tag.parent.should be nil
      Tag.roots.should include @tag
    end
    it "will be valid when #new'd and assigned own parent (but not yet saved)" do
      # Bug or feature? Can't assign parent properly unless id created
      @tag = Tag.new
      @tag.parent = @tag
      @tag.should be_valid
    end
    it "should not allow destruction if unremovable" do    
      @tag.removable = false
      @tag.destroy.should be false
    end
  end
  
  describe "validations" do
    
  end
  
  
end
# context "Tags" do
#   
#   context "with contacts" do
#     setup do
#       @contact = get_a_contact
#     end
#     should "be able to have a contact" do
#       assert @contact.tags.count == 0
#       @contact.tags = [@tag]
#       assert @contact.save
#       assert @contact.tags.count == 1
#     end
# 
#     should "be able to delete tag" do
#       @contact.tags = [@tag]
#       @contact.save
#       assert @contact.tags.length == 1
#       assert @tag.destroy
#       @contact.reload
#       assert @contact.tags.length == 0
#     end
# 
#     should "can delete a contact with a tag" do
#       @contact.tags = [@tag]
#       @contact.save
#       @contact.reload
#       assert @contact.destroy
#     end
#   end
# end
# 
# should "can mass reassign children" do
#   t = Tag.find 4
#   children = t.children
#   tccount = children.length
#   t2 = Tag.find 1
#   t2ccount = t2.children.length
#   assert t2.children << children
#   assert t2.save
#   t2.reload
#   assert (t2.children.length == tccount + t2ccount)
# end
