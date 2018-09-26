#import "ZJNewFeatureController.h"
#import "ZJNewFeatureCell.h"
#import "FileAccessor.h"

@interface ZJNewFeatureController () {
    NSArray *_picStrArr;
    UIPageControl *_control;
}

@end

@implementation ZJNewFeatureController

static NSString * const reuseIdentifier = @"NewFeatureCell";

- (instancetype)initWithArray:(NSArray *)picStrArr
{
    _picStrArr = picStrArr;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    // 设置cell的尺寸
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    // 清空行距
    layout.minimumLineSpacing = 0;
    
    // 设置滚动的方向
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return [super initWithCollectionViewLayout:layout];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册cell,默认就会创建这个类型的cell
    [self.collectionView registerClass:[ZJNewFeatureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 分页
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    // 添加pageController
     [self setUpPageControl];
}

// 添加pageController
- (void)setUpPageControl
{
    // 添加pageController,只需要设置位置，不需要管理尺寸
    UIPageControl *control = [[UIPageControl alloc] init];
    
    control.numberOfPages = _picStrArr.count;
    control.pageIndicatorTintColor = [UIColor whiteColor];
    control.currentPageIndicatorTintColor = [UIColor grayColor];
    
    // 设置center
    control.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height - 20);
    _control = control;
    [self.view addSubview:control];
}

#pragma mark - UIScrollView代理
// 只要一滚动就会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 获取当前的偏移量，计算当前第几页
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5;
    
    // 设置页数
    _control.currentPage = page;
    
//    if (scrollView.contentOffset.x > (_count - 1 + 0.25)*ScreenWidth) {
//        
//        [self startClick];
//    }
}
#pragma mark - UICollectionView代理和数据源
// 返回有多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// 返回第section组有多少个cell
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _picStrArr.count;
}

// 返回的cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    ZJNewFeatureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *imageName = [_picStrArr objectAtIndex:indexPath.row];
    
    NSString *filePath = [[FileAccessor getInstance] constructAbsolutePath:[NSString stringWithFormat:@"doc/%@", imageName]];
    cell.image = [UIImage imageWithContentsOfFile:filePath];
    
    [cell setIndexPath:indexPath count:_picStrArr.count];
    return cell;
    
}

@end
