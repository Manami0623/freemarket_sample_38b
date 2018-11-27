require 'rails_helper'

describe ItemsController, type: :controller do

  describe 'GET #index' do

    let(:user) { create(:user) }
    let(:items) { create_list(:item, 5, user_id: user.id) }
    context 'ログイン中' do
      before do
        login user
        get :index
      end

      it "populates an array of item ordered by created_at DESC" do
        expect(assigns(:items)).to match(items.sort{ |a, b| b.created_at <=> a.created_at })
      end

      it "renders the :index template" do
        expect(response).to render_template :index
      end
    end

    context 'ログアウト中' do
      before do
        get :index
      end
      it "populates an array of item ordered by created_at DESC" do
        expect(assigns(:items)).to match(items.sort{ |a, b| b.created_at <=> a.created_at })
      end

      it "renders the :index template" do
        expect(response).to render_template :index
      end
    end
  end

  describe 'GET #new' do

    let(:user) { create(:user) }
    let(:item) { create(:item) }
    let(:categories) { create_list(:category, 3) }
    let(:sizes) { create_list(:size, 2) }
    let(:brands) { create_list(:brand, 2) }
    let(:prefectures) { create_list(:prefecture, 2) }

    context 'ログイン中' do
      before do
        login user
        get :new
      end

      it 'ビューが期待通りのものになっているか' do
        expect(response).to render_template :new
      end

      it '@itemがあるか' do
        expect(assigns(:item)).to be_a_new(Item)
      end

      it '@categoriesがあるか' do
        expect(assigns(:categories)).to eq(categories)
      end

      it '@sizesがあるか' do
        expect(assigns(:sizes)).to eq(sizes)
      end

      it '@brandsがあるか' do
        expect(assigns(:brands)).to eq(brands)
      end

      it '@prefecturesがあるか' do
        expect(assigns(:prefectures)).to eq(prefectures)
      end

    end

  describe 'Get #edit' do
     it "assigns the requested item to @items" do
       item = create(:item)
       get :edit, id: item
      expect(assigns(:item)).to be_a_new(Item)
    end

     it "assigns the requested item to @categories" do
       expect(assigns(:categories)).to eq(categories)
    end

     it "assigns the requested item to @sizes" do
       expect(assigns(:sizes)).to eq(sizes)
    end

     it "assigns the requested item to @barands" do
       expect(assigns(:brands)).to eq(brands)
    end

     it "assigns the requested item to @prefectures" do
       expect(assigns(:prefectures)).to eq(prefectures)
    end

    it "renders the :edit template" do
      item = create(:item)
      get :edit, id: item
      expect(response).to render_template :edit
    end

  end


    context '未ログイン' do
      it 'new_user_sesssion_pathにリダイレクトされるか' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:item) { create(:item, user_id: user.id, prefecture_id: prefecture.id) }
    let(:prefecture) { create(:prefecture) }
    let(:params) {{ item: attributes_for(:item, category_ids: [], user_id: user.id, prefecture_id: prefecture.id) }}
    context 'ログイン中' do
      before do
        login user
      end
      context '保存できる' do
        subject {
          post :create,
          params: params
        }

        it 'itemが増えたかどうか' do
          category_ids = []
          item.categories.each do |category|
            category_ids << category.id
          end
          params[:item][:category_ids] = category_ids
          src = [item.item_images[0].item_image_src]
          params[:item][:item_images_attributes] = { "0": { "item_image_src": src } }
          expect{ subject }.to change(Item, :count).by(1)
        end
      end

      context '保存できない' do
        it 'new_item_pathにリダイレクトされるか' do
          post :create, params: params
          expect(response).to render_template(:new)
        end
      end
    end

    context '未ログイン' do
      it 'new_user_sesssion_pathにリダイレクトされるか' do
        post :create
        expect(response).to redirect_to(new_user_session_path)
      end
    end

  end

end
